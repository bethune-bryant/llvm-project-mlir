// This tests checks the following aspects of lowering component:
// * Has the correct attribute to output tensor

// RUN: mlir-opt -miopen-lowering -split-input-file %s | FileCheck %s

func @miopen_conv2d_gkyxc_nhwgc_nhwgk(%filter : memref<1x128x3x3x8xf32>, %input : memref<128x32x32x1x8xf32>, %output : memref<128x30x30x1x128xf32>) {
  miopen.conv2d(%filter, %input, %output) {
    arch = "gfx906",
    num_cu = 64,
    filter_layout = ["g", "k", "y", "x", "c"],
    input_layout = ["ni", "hi", "wi", "gi", "ci"],
    output_layout = ["no", "ho", "wo", "go", "ko"],
    dilations = [1, 1],
    strides = [1, 1],
    padding = [0, 0, 0, 0]
  } : memref<1x128x3x3x8xf32>, memref<128x32x32x1x8xf32>, memref<128x30x30x1x128xf32>
  return
}
// CHECK-LABEL: func @miopen_conv2d
// CHECK:       miopen.transform(%arg2)
// CHECK:       lower_layer_names = ["go"]
// CHECK:       upper_layer_names = ["gemmG"]
// CHECK:       lower_layer_names = ["ko"]
// CHECK:       upper_layer_names = ["gemmM"]
// CHECK:       lower_layer_names = ["no", "ho", "wo"]
// CHECK:       upper_layer_names = ["gemmN"]
// CHECK:       miopen.gridwise_gemm

func @miopen_conv2d_bwd_data_gkyxc_nhwgc_nhwgk(%filter : memref<1x128x3x3x8xf32>, %input : memref<128x32x32x1x8xf32>, %output : memref<128x30x30x1x128xf32>) {
  miopen.conv2d_bwd_data(%filter, %input, %output) {
    arch = "gfx906",
    num_cu = 64,
    filter_layout = ["g", "k", "y", "x", "c"],
    input_layout = ["ni", "hi", "wi", "gi", "ci"],
    output_layout = ["no", "ho", "wo", "go", "ko"],
    dilations = [1, 1],
    strides = [1, 1],
    padding = [0, 0, 0, 0],
    gemm_id = 0
  } : memref<1x128x3x3x8xf32>, memref<128x32x32x1x8xf32>, memref<128x30x30x1x128xf32>
  return
}
// CHECK-LABEL: func @miopen_conv2d_bwd_data
// CHECK:       miopen.transform(%arg2)
// CHECK:       lower_layer_names = ["go"]
// CHECK:       upper_layer_names = ["gemmG"]
// CHECK:       lower_layer_names = ["ko", "ydotslice", "xdotslice"]
// CHECK:       upper_layer_names = ["gemmK"]
// CHECK:       lower_layer_names = ["no", "htildaslice", "wtildaslice"]
// CHECK:       upper_layer_names = ["gemmN"]
// CHECK:       miopen.gridwise_gemm

func @miopen_conv2d_bwd_weight_gkyxc_nhwgc_nhwgk(%filter : memref<1x128x3x3x8xf32>, %input : memref<128x32x32x1x8xf32>, %output : memref<128x30x30x1x128xf32>) {
  miopen.conv2d_bwd_weight(%filter, %input, %output) {
    arch = "gfx906",
    num_cu = 64,
    filter_layout = ["g", "k", "y", "x", "c"],
    input_layout = ["ni", "hi", "wi", "gi", "ci"],
    output_layout = ["no", "ho", "wo", "go", "ko"],
    dilations = [1, 1],
    strides = [1, 1],
    padding = [0, 0, 0, 0]
  } : memref<1x128x3x3x8xf32>, memref<128x32x32x1x8xf32>, memref<128x30x30x1x128xf32>
  return
}
// CHECK-LABEL: func @miopen_conv2d_bwd_weight
// CHECK:       miopen.transform(%arg2)
// CHECK:       lower_layer_names = ["go"]
// CHECK:       upper_layer_names = ["gemmG"]
// CHECK:       lower_layer_names = ["no", "ho", "wo"]
// CHECK:       upper_layer_names = ["gemmK"]
// CHECK:       lower_layer_names = ["ko"]
// CHECK:       upper_layer_names = ["gemmM"]
// CHECK:       miopen.gridwise_gemm
