ifndef intermediates-dir-for
define intermediates-dir-for
$(strip \
    $(eval _idfClass := $(strip $(1))) \
    $(if $(_idfClass),, \
      $(error $(LOCAL_PATH): Class not defined in call to intermediates-dir-for)) \
    $(eval _idfName := $(strip $(2))) \
    $(if $(_idfName),, \
      $(error $(LOCAL_PATH): Name not defined in call to intermediates-dir-for)) \
    $(eval _idfPrefix := $(if $(strip $(3)),HOST,TARGET)) \
    $(if $(filter $(_idfPrefix)-$(_idfClass),$(COMMON_MODULE_CLASSES))$(4), \
      $(eval _idfIntBase := $($(_idfPrefix)_OUT_COMMON_INTERMEDIATES)) \
      , \
      $(eval _idfIntBase := $($(_idfPrefix)_OUT_INTERMEDIATES)) \
     ) \
    $(_idfIntBase)/$(_idfClass)/$(_idfName)_intermediates \
 )
endef
endif

INTERNAL_RECOVERY_FILES := $(filter $(TARGET_RECOVERY_OUT)/%, \
	$(foreach module, $(ALL_MODULES), $(ALL_MODULES.$(module).INSTALLED)) \
	$(ALL_DEFAULT_INSTALLED_MODULES))

MAKE_EXT4FS := $(addprefix $(TARGET_ROOT_OUT)/bin/, make_ext4fs)

TARGET_DEVICE_DIR := device/samsung/galaxys_sc02b

recovery_uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.cpio
recovery_initrc := $(TARGET_DEVICE_DIR)/recovery.rc
recovery_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.img
recovery_build_prop := $(INSTALLED_BUILD_PROP_TARGET)
recovery_binary := $(call intermediates-dir-for,EXECUTABLES,recovery)/recovery
recovery_resources_common := $(call include-path-for, recovery)/res
recovery_resources_private := $(TARGET_DEVICE_DIR)/recovery/res
recovery_resource_deps := $(shell find $(recovery_resources_common) \
  $(recovery_resources_private) -type f)
recovery_fstab := $(TARGET_DEVICE_DIR)/recovery.fstab

TARGET_RECOVERY_ROOT_TIMESTAMP := $(TARGET_RECOVERY_OUT)/root.ts

$(TARGET_RECOVERY_ROOT_TIMESTAMP): $(INTERNAL_RECOVERY_FILES) \
		$(INSTALLED_RAMDISK_TARGET) \
		$(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) \
		$(recovery_binary) \
		$(recovery_initrc) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_prop) $(recovery_resource_deps) \
		$(recovery_fstab)
	$(info ----- Making recovery filesystem ------)
	mkdir -p $(TARGET_RECOVERY_OUT)
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/etc
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/tmp
	$(info Copying baseline ramdisk...)
	cp -R $(TARGET_ROOT_OUT) $(TARGET_RECOVERY_OUT)
	rm $(TARGET_RECOVERY_ROOT_OUT)/init*.rc
	$(info Modifying ramdisk contents...)
	cp -f $(recovery_initrc) $(TARGET_RECOVERY_ROOT_OUT)/init.rc
	cp -f $(recovery_binary) $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	cp -f $(MAKE_EXT4FS) $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	rm -f $(TARGET_RECOVERY_ROOT_OUT)/init.*.rc
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/system/bin
	cp -rf $(recovery_resources_common) $(TARGET_RECOVERY_ROOT_OUT)/
	$(foreach item,$(recovery_resources_private), \
	  cp -rf $(item) $(TARGET_RECOVERY_ROOT_OUT)/)
	$(foreach item,$(recovery_root_private), \
	  cp -rf $(item) $(TARGET_RECOVERY_OUT)/)
	$(foreach item,$(recovery_fstab), \
	  cp -f $(item) $(TARGET_RECOVERY_ROOT_OUT)/etc/recovery.fstab)
	cat $(INSTALLED_DEFAULT_PROP_TARGET) $(recovery_build_prop) \
	        > $(TARGET_RECOVERY_ROOT_OUT)/default.prop
	$(info Modifying default.prop)
	sed -i 's/ro.build.date.utc=.*/ro.build.date.utc=0/g' $(TARGET_RECOVERY_ROOT_OUT)/default.prop
	$(info ----- Made recovery filesystem -------- $(TARGET_RECOVERY_ROOT_OUT))
	@touch $(TARGET_RECOVERY_ROOT_TIMESTAMP)

$(recovery_uncompressed_ramdisk): $(MINIGZIP) \
    $(TARGET_RECOVERY_ROOT_TIMESTAMP)
	$(info ----- Making uncompressed recovery ramdisk ------)
	$(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

$(recovery_ramdisk): $(MKBOOTFS) \
    $(recovery_uncompressed_ramdisk)
	$(info ----- Making recovery ramdisk ------)
	$(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $@
