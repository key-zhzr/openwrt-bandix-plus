include $(TOPDIR)/rules.mk

PKG_NAME:=bandix-plus
PKG_VERSION:=0.1.6
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=timsaya

include $(INCLUDE_DIR)/package.mk

# 使用OpenWrt的Rust映射机制
include $(TOPDIR)/feeds/packages/lang/rust/rust-values.mk

# 二进制文件的文件名和URL
RUST_BANDIX_PLUS_VERSION:=0.1.6
RUST_BINARY_FILENAME:=bandix-plus-$(RUST_BANDIX_PLUS_VERSION)-$(RUSTC_TARGET_ARCH).tar.gz


# 修正下载地址定义方式
PKG_SOURCE:=$(RUST_BINARY_FILENAME)
PKG_SOURCE_URL:=https://github.com/key-zhzr/bandix-plus/releases/download/v$(RUST_BANDIX_PLUS_VERSION)

# 修正二进制文件校验值
ifeq ($(ARCH),aarch64)
	PKG_HASH:=43ec7d6b0e0c8f797b70ad0db48e3c538ee0de6f9c7d1765a73fccc762426fa3
else
	# v0.1.6 release branch publishes only the target needed by the SNAPSHOT APK build.
	PKG_HASH:=dummy
endif

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Bandix Plus - Network traffic monitoring tool
	DEPENDS:=+zoneinfo-all +conntrack +iw
endef

define Package/$(PKG_NAME)/description
	Bandix Plus core service for network traffic monitoring
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/bin
	gzip -dc "$(DL_DIR)/$(PKG_SOURCE)" | tar -C $(PKG_BUILD_DIR)/bin --strip-components=1 -xf -
	$(Build/Patch)
endef

define Build/Compile
	# nothing to do
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bandix-plus $(1)/usr/bin/

	# 添加启动脚本和配置文件
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/bandix-plus.init $(1)/etc/init.d/bandix-plus

	# 安装配置文件
	$(INSTALL_DIR) $(1)/usr/share/bandix-plus
	$(INSTALL_CONF) ./files/bandix_plus.config $(1)/etc/config/bandix_plus

	# 安装 UCI defaults（仅补齐缺失配置项，不覆盖用户已有值）
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-bandix-plus-defaults $(1)/etc/uci-defaults/99-bandix-plus-defaults
	
	# 配置 sysupgrade 保留列表
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/bandix-plus.keep $(1)/lib/upgrade/keep.d/bandix-plus
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/bandix_plus
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] && exit 0

DEFAULTS_SCRIPT="/etc/uci-defaults/99-bandix-plus-defaults"
if [ -x "$$DEFAULTS_SCRIPT" ]; then
	"$$DEFAULTS_SCRIPT" && rm -f "$$DEFAULTS_SCRIPT"
fi

exit 0
endef

$(eval $(call BuildPackage,bandix-plus))
