# Copyright (C) 2007 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# BoardConfig.mk
#
# Product-specific compile-time definitions.
#

#Video Devices
BOARD_SECOND_CAMERA_DEVICE := /dev/video2

# Kernel Config
TARGET_KERNEL_CONFIG := cyanogenmod_galaxys_sc02b_defconfig

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/samsung/galaxys_sc02b/bluetooth

# Recovery
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../device/samsung/galaxys_sc02b/recovery/recovery_keys.c

TARGET_OTA_ASSERT_DEVICE := galaxys,galaxysmtd,GT-I9000,GT-I9000M,GT-I9000T,SC-02B

# Import the aries-common BoardConfigCommon.mk
include device/samsung/aries-common/BoardConfigCommon.mk

TARGET_KERNEL_SOURCE := kernel/samsung/galaxys_sc02b
BOARD_CUSTOM_BOOTIMG_MK := device/samsung/galaxys_sc02b/shbootimg.mk

TARGET_RELEASETOOLS_EXTENSIONS := device/samsung/galaxys_sc02b
