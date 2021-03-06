#############################################################
#
# dhcp
#
#############################################################
DHCP_VERSION:=3.0.5
DHCP_SOURCE:=dhcp-$(DHCP_VERSION).tar.gz
DHCP_SITE:=ftp://ftp.isc.org/isc/dhcp/dhcp-3.0-history
DHCP_CAT:=$(ZCAT)
DHCP_DIR:=$(BUILD_DIR)/dhcp-$(DHCP_VERSION)
DHCP_SERVER_BINARY:=work.linux-2.2/server/dhcpd
DHCP_RELAY_BINARY:=work.linux-2.2/relay/dhcrelay
DHCP_CLIENT_BINARY:=work.linux-2.2/client/dhclient
DHCP_SERVER_TARGET_BINARY:=usr/sbin/dhcpd
DHCP_RELAY_TARGET_BINARY:=usr/sbin/dhcrelay
DHCP_CLIENT_TARGET_BINARY:=usr/sbin/dhclient
BVARS=PREDEFINES='-D_PATH_DHCPD_DB=\"/var/lib/dhcp/dhcpd.leases\" \
	-D_PATH_DHCLIENT_DB=\"/var/lib/dhcp/dhclient.leases\"' \
	VARDB=/var/lib/dhcp

$(DL_DIR)/$(DHCP_SOURCE):
	 $(WGET) -P $(DL_DIR) $(DHCP_SITE)/$(DHCP_SOURCE)

dhcp-source: $(DL_DIR)/$(DHCP_SOURCE)

dhcp_server-source: dhcp-source
dhcp_relay-source: dhcp-source
dhcp_client-source: dhcp-source

$(DHCP_DIR)/.unpacked: $(DL_DIR)/$(DHCP_SOURCE)
	$(DHCP_CAT) $(DL_DIR)/$(DHCP_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(DHCP_DIR) package/dhcp/ dhcp\*.patch
	touch $@

$(DHCP_DIR)/.configured: $(DHCP_DIR)/.unpacked
	(cd $(DHCP_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure; \
	)
	touch $@

$(DHCP_DIR)/$(DHCP_RELAY_BINARY): $(DHCP_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) $(BVARS) -C $(DHCP_DIR)
	$(STRIPCMD) $(DHCP_DIR)/$(DHCP_RELAY_BINARY)

$(TARGET_DIR)/$(DHCP_SERVER_TARGET_BINARY): $(DHCP_DIR)/$(DHCP_RELAY_BINARY)
	mkdir -p $(TARGET_DIR)/var/lib
	(cd $(TARGET_DIR)/var/lib; \
		ln -snf /tmp dhcp; \
	)
	$(INSTALL) -m 0755 -D $(DHCP_DIR)/$(DHCP_SERVER_BINARY) \
		$(TARGET_DIR)/$(DHCP_SERVER_TARGET_BINARY)
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 -D package/dhcp/S80dhcp-server \
		$(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/etc/dhcp
	$(INSTALL) -m 0644 -D package/dhcp/dhcpd.conf \
		$(TARGET_DIR)/etc/dhcp/dhcpd.conf
ifneq ($(BR2_HAVE_INFOPAGES),y)
	rm -rf $(TARGET_DIR)/usr/info
endif
ifneq ($(BR2_HAVE_MANPAGES),y)
	rm -rf $(TARGET_DIR)/usr/man
endif
	rm -rf $(TARGET_DIR)/share/locale
	rm -rf $(TARGET_DIR)/usr/share/doc

$(TARGET_DIR)/$(DHCP_RELAY_TARGET_BINARY): $(DHCP_DIR)/$(DHCP_RELAY_BINARY)
	mkdir -p $(TARGET_DIR)/var/lib
	(cd $(TARGET_DIR)/var/lib; ln -snf /tmp dhcp)
	$(INSTALL) -m 0755 -D $(DHCP_DIR)/$(DHCP_RELAY_BINARY) \
		$(TARGET_DIR)/$(DHCP_RELAY_TARGET_BINARY)
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 -D package/dhcp/S80dhcp-relay \
		$(TARGET_DIR)/etc/init.d
ifneq ($(BR2_HAVE_INFOPAGES),y)
	rm -rf $(TARGET_DIR)/usr/info
endif
ifneq ($(BR2_HAVE_MANPAGES),y)
	rm -rf $(TARGET_DIR)/usr/man
endif
	# Why on earth do we wipe out whole directories here?
	#rm -rf $(TARGET_DIR)/usr/share/locale
	#rm -rf $(TARGET_DIR)/usr/share/doc

$(TARGET_DIR)/$(DHCP_CLIENT_TARGET_BINARY): $(DHCP_DIR)/$(DHCP_RELAY_BINARY)
	mkdir -p $(TARGET_DIR)/var/lib
	(cd $(TARGET_DIR)/var/lib; ln -snf /tmp dhcp)
	$(INSTALL) -m 0755 -D $(DHCP_DIR)/$(DHCP_CLIENT_BINARY) \
		$(TARGET_DIR)/$(DHCP_CLIENT_TARGET_BINARY)
	mkdir -p $(TARGET_DIR)/etc/dhcp
	$(INSTALL) -m 0644 -D package/dhcp/dhclient.conf \
		$(TARGET_DIR)/etc/dhcp/dhclient.conf
	$(INSTALL) -m 0755 -D package/dhcp/dhclient-script \
		$(TARGET_DIR)/sbin/dhclient-script
ifneq ($(BR2_HAVE_INFOPAGES),y)
	rm -rf $(TARGET_DIR)/usr/info
endif
ifneq ($(BR2_HAVE_MANPAGES),y)
	rm -rf $(TARGET_DIR)/usr/man
endif
	# Why on earth do we wipe out whole directories here?
	#rm -rf $(TARGET_DIR)/usr/share/locale
	#rm -rf $(TARGET_DIR)/usr/share/doc

dhcp_server: uclibc $(TARGET_DIR)/$(DHCP_SERVER_TARGET_BINARY)

dhcp_relay: uclibc $(TARGET_DIR)/$(DHCP_RELAY_TARGET_BINARY)

dhcp_client: uclibc $(TARGET_DIR)/$(DHCP_CLIENT_TARGET_BINARY)

dhcp-clean:
	-$(MAKE) -C $(DHCP_DIR) clean

dhcp-dirclean:
	rm -rf $(DHCP_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_ISC_DHCP)),y)
#TARGETS+=dhcp
#endif
ifeq ($(strip $(BR2_PACKAGE_DHCP_SERVER)),y)
TARGETS+=dhcp_server
endif
ifeq ($(strip $(BR2_PACKAGE_DHCP_RELAY)),y)
TARGETS+=dhcp_relay
endif
ifeq ($(strip $(BR2_PACKAGE_DHCP_CLIENT)),y)
TARGETS+=dhcp_client
endif
