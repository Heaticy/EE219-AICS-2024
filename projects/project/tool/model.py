import os
import math
import argparse
import torch 
import torchvision
import torchvision.transforms as transforms
from PIL import Image
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

CIFAR10_PATH    = "/home/ubuntu/data"
MODEL_PATH      = "model_lab2.pth"
BIN_SAVE_PATH   = "../data/bin/"
NPY_SAVE_PATH   = "../data/npy/"

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

parser  = argparse.ArgumentParser()
parser.add_argument("--input_nhwc",type=str2bool,default=False)
parser.add_argument("--conv_weight_nhwc",type=str2bool,default=False)
parser.add_argument("--fc_weight_trans",type=str2bool,default=False)
parser.add_argument("--batch", type=int, default=10)
CIFAR10_CLASS   = ["airplane","automobile","bird","cat","deer","dog","frog","horse","ship","truck"]

class Network(nn.Module):
    def __init__(self):
        super(Network, self).__init__()
        self.conv1  = nn.Conv2d(3, 12, 5, bias=False)
        self.pool   = nn.MaxPool2d(2, 2)
        self.conv2  = nn.Conv2d(12, 32, 3, bias=False)
        self.fc1    = nn.Linear(32 * 6 * 6, 256, bias=False)
        self.fc2    = nn.Linear(256, 64, bias=False)
        self.fc3    = nn.Linear(64, 10, bias=True)
    def quantize(self, x, scale, is_input=False):
        if not is_input:
            n = round(math.log2(scale))
            #print(scale,2**n)
            x = torch.clamp(torch.round(x/(2**n)), min=-128, max=127)
        else:
            x = torch.clamp(torch.round(x/scale), min=-128, max=127)
        return x
    def forward(self,x):
        x = self.quantize(x, self.input_scale, is_input=True)
        x = F.relu(self.conv1(x))
        x = self.quantize(x, self.conv1.output_scale, is_input=False)
        print(f"CONV1 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outconv1.npy", x.numpy().astype(np.int8))
        x = self.pool(x)
        print(f"POOL1 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outpool1.npy", x.numpy().astype(np.int8))
        x = F.relu(self.conv2(x))
        x = self.quantize(x, self.conv2.output_scale, is_input=False)
        print(f"CONV2 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outconv2.npy", x.numpy())
        x = self.pool(x)
        print(f"POOL2 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outpool2.npy", x.numpy().astype(np.int8))
        x = x.view(-1, 32 * 6 * 6)
        x = F.relu(self.fc1(x))
        x = self.quantize(x, self.fc1.output_scale, is_input=False)
        print(f"FC1 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outfc1.npy", x.numpy().astype(np.int8))
        x = F.relu(self.fc2(x))
        x = self.quantize(x, self.fc2.output_scale, is_input=False)
        print(f"FC2 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outfc2.npy", x.numpy().astype(np.int8))
        x = self.fc3(x)
        x = self.quantize(x, self.fc3.output_scale, is_input=False)
        print(f"FC3 output shape: {x.shape}")
        np.save(NPY_SAVE_PATH+"outfc3.npy", x.numpy().astype(np.int8))
        return x

def load_model( path ):
    model = torch.load(path,weights_only=False)
    return model

def get_testloader():
    transform = transforms.Compose(
        [transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))])
    testset = torchvision.datasets.CIFAR10(root=CIFAR10_PATH, train=False,
                                        download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=1,shuffle=False, num_workers=2)
    return testloader 

def gen_testcase(testloader, batch=1):
    cnt = 0 
    images_set = []
    labels_set = []
    for data in testloader:
        images, labels = data
        images_set.append(images)
        labels_set.append(labels)
        cnt += 1 
        if cnt>=batch:
            break 
    return images_set, labels_set

def export_img(tensor_img,filepath):
    numpy_data = tensor_img.squeeze(0).permute(1,2,0).numpy()
    numpy_data = (numpy_data-numpy_data.min())/(numpy_data.max()-numpy_data.min())*255
    numpy_data = numpy_data.astype(np.uint8)
    #print(numpy_data.shape)
    img = Image.fromarray(numpy_data)
    img.save(filepath)
    
if __name__=='__main__':
    args        = parser.parse_args()
    model       = load_model(MODEL_PATH)
    test_loader = get_testloader()
    images_set, labels_set = gen_testcase(test_loader, batch=args.batch)

    # select the data to be saved
    index       = 3
    input_img   = images_set[index]
    #export_img(input_img, '../img.png')
    
    # golden result
    with torch.no_grad():
        print(f"Quantized model inference golden result: {model(input_img).tolist()[0]}")
    print(f"Groundtruth of this image: {CIFAR10_CLASS[labels_set[index]]}")

    input_scaled = torch.clamp(torch.round(input_img/model.input_scale), min=-128, max=127)

    # quantized input 
    img_data    = input_scaled.data[0]
    img_data    = np.array(img_data,dtype=np.int8)
    #print(img_data)
    if args.input_nhwc:
        img_data = img_data.transpose(1,2,0)
    with open(BIN_SAVE_PATH+"data.bin", "wb") as f:
        img_data.tofile(f)
    print(f"Shape of the input image: {img_data.shape}")
    print("------------------------------------------------------------------------------------------------")

    # quantized weights and fc3 bias
    for name,layer in model.named_children():
        if hasattr(layer,'weight'):
            weight_data         = layer.weight.data
            weight_data         = np.array(weight_data,dtype=np.int8)
            if 'conv' in name and args.conv_weight_nhwc:
                weight_data = weight_data.transpose(0,2,3,1)
            if 'fc' in name and args.fc_weight_trans:
                weight_data = weight_data.transpose(1,0)
            with open(BIN_SAVE_PATH+"data.bin", "ab") as f:
                weight_data.tofile(f)
            print(f"Shape of the int8 {name} weight is: {weight_data.shape}")
        
        if hasattr(layer,'bias') and layer.bias is not None:
            bias_data           = layer.bias.data
            bias_data           = np.array(bias_data,dtype=np.int16)
            with open(BIN_SAVE_PATH+"data.bin", "ab") as f:
                bias_data.tofile(f)
            print(f"Shape of the int16 {name} bias is: {bias_data.shape}")

        if hasattr(layer,'output_scale') and layer.output_scale is not None:
            fp_scale            = layer.output_scale
            round_shift_bits    = round(math.log2(fp_scale))
            power_of_two_scale  = 2**round_shift_bits
            scale_data          = np.array(round_shift_bits,dtype=np.int8)
            with open(BIN_SAVE_PATH+"data.bin", "ab") as f:
                scale_data.tofile(f)
            print(f"Output scale for {name} is {fp_scale:.3f} but is quantized to {power_of_two_scale}, which can be implemented by >> {round_shift_bits} bits.")
            print("------------------------------------------------------------------------------------------------")

    print('Quantized input and weight data has all been successfully saved.')
