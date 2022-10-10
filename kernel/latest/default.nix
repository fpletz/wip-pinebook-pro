# By design this is not "pinning" to any particular kernel version.
# This means that, by design, it may start failing once the patches don't apply.
# But, by design, this will track the kernel upgrades in Nixpkgs.
{ pkgs, lib, linux_latest, kernelPatches, fetchpatch, ... } @ args:

let
  manjaroArmPatch = patch: sha256: let rev = "16eeb5e62e861532994de256159cfc0de670d00e"; in {
    name = patch;
    patch = (fetchpatch {
      url = "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux/-/raw/${rev}/${patch}";
      inherit sha256;
    });
  };
  megousPatch = rev: sha256: {
    name = "megous-linux-${rev}";
    patch = (fetchpatch {
      url = "https://github.com/megous/linux/commit/${rev}.diff";
      inherit sha256;
    });
  };
in
linux_latest.override({
  kernelPatches = lib.lists.unique (kernelPatches ++ [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper

    # Kernel configuration
    {
      # None of these *need* to be set to `y`.
      # But eh, it works too
      name = "pinebookpro-config";
      patch = null;
      extraConfig = ''
        PCIE_ROCKCHIP y
        PCIE_ROCKCHIP_HOST y
        PCIE_DW_PLAT y
        PCIE_DW_PLAT_HOST y
        PHY_ROCKCHIP_PCIE y
        PHY_ROCKCHIP_INNO_HDMI y
        PHY_ROCKCHIP_DP y
        ROCKCHIP_MBOX y
        USB_DWC2_PCI y
        ROCKCHIP_LVDS y
        ROCKCHIP_RGB y
      '';
    }
    {
      name = "video-hantro-config";
      patch = null;
      extraConfig = ''
        STAGING_MEDIA y
        VIDEO_HANTRO m
        VIDEO_HANTRO_ROCKCHIP y
      '';
    }
    {
      name = "minimal-config";
      patch = null;
      extraConfig = ''
        MEDIA_TUNER n
        DVB_USB n
        FUSION n
        CAN n
      '';
    }

    # Misc. community patches
    # None are *required* for basic function.
    # https://gitlab.manjaro.org/manjaro-arm/packages/core/linux
    #(manjaroArmPatch"0001-arm64-dts-rockchip-Add-back-cdn_dp-to-Pinebook-Pro.patch" "sha256-RMh9Y7b1K+9rgC+PQaz3RU4UgzSj0HZEGRK2ZDilqi4=")
    #(manjaroArmPatch"0002-arm64-dts-allwinner-add-hdmi-sound-to-pine-devices.patch" "sha256-/YLSXyUU+58ugL6OLpvuwAo37VN0MMM+i7Ly5UI4fUA=")
    #(manjaroArmPatch"0004-drm-bridge-analogix_dp-Add-enable_psr-param.patch" "sha256-W4o4Qa4f625SMcl6NCfeXHlWnYIceYdbEQGlHLET+Sg=")
    #(manjaroArmPatch"0006-nuumio-panfrost-Silence-Panfrost-gem-shrinker-loggin.patch" "sha256-bw3+erGlxJfbLwtifLfyd6zT5dCXXAYkoWNk52xjQzI=")
    #(manjaroArmPatch"0008-typec-displayport-some-devices-have-pin-assignments-reversed.patch" "sha256-j3hhPntf1aXKzwen+cY9GP5Ihr5gpaw9O4B0kqecqwk=")
    #(manjaroArmPatch"0009-Add-megis-extcon-changes-to-fusb302.patch" "sha256-GwMo98YvhpdrEfgxey8uuTES/pqvOOCyA7cw21cM+AA=")
    #(manjaroArmPatch"0010-usb-typec-Add-megis-typex-to-extcon-bridge-driver.patch" "sha256-SqS5u/miZsjzw/nv3ko/RHXuZDknXdl1rVuvG+/8bj4=")
    ##(manjaroArmPatch"0011-arm64-rockchip-add-DP-ALT-rockpro64.patch" "071n9mhmz8m6gmhb1lf2kfkbwwz1sf1c77pcpi2xsvfd409l5xjr")
    #(manjaroArmPatch"0012-ayufan-drm-rockchip-add-support-for-modeline-32MHz-e.patch" "sha256-npGwg0fqJUUPaoyhhwlswvzdcAab4PELLUTKBTbkoXw=")
    #(manjaroArmPatch"0013-rk3399-rp64-pcie-Reimplement-rockchip-PCIe-bus-scan-delay.patch" "sha256-6c64k47hnuKL+A+QjDBPSgT1dwTUlIjbhHGhwGZk7xI=")
    ##(manjaroArmPatch"0014-phy-rockchip-typec-Set-extcon-capabilities.patch" "0pqq856g0yndxvg9ipbx1jv6j4ldvapgzvxzvpirygc7f0wdrz49")
    ##(manjaroArmPatch"0015-usb-typec-altmodes-displayport-Add-hacky-generic-altmode.patch" "1vldwg3zwrx2ppqgbhc91l48nfmjkmwwdsyq6mq6f3l1cwfdn62q")
    ##(manjaroArmPatch"0017-arm64-dts-rockchip-setup-USB-type-c-port-as-dual-data-role.patch" "0zwwyhryghafga36mgnazn6gk88m2rvs8ng5ykk4hhg9pi5bgzh9")
    #(manjaroArmPatch"0014-arm64-dts-rockchip-add-typec-extcon-hack.patch" "sha256-FBtEISaJb9d7/GaHWrREmgIxVJvF8TS0+zbLjNs5O+8=")
    ##(manjaroArmPatch"0015-drm-meson-add-YUV422-output-support.patch" "sha256-Z6VwGqyuUB1F/PYl0nxA/xkSZTlbDr39YSx0DJTG3sc=")
    ##(manjaroArmPatch"0019-arm64-dts-meson-add-initial-Beelink-GT1-Ultimate-dev.patch" "0wyqkly38j7b78d73x95pbphlc68i2pf77akjbc5rrdl2n1hc6vr")
    #(manjaroArmPatch"0017-add-ugoos-device.patch" "sha256-4YoT5pK70aG7EZBghn47JbFqq0qCl1iVUgWMQV223Ec=")
    #(manjaroArmPatch"0018-drm-panfrost-scheduler-fix.patch" "sha256-Mn26wYj7m8r26JZ/7pa0WBo7rgCA/RW6Nzph/g9MKyE=")
    #(manjaroArmPatch"0019-arm64-dts-rockchip-Add-pcie-bus-scan-delay-to-rockpr.patch" "sha256-puZtq9kwOQp27i9PZEhsswfwbe5WVtH/uc6wESsDn8A=")
    #(manjaroArmPatch"0020-drm-rockchip-support-gamma-control-on-RK3399.patch" "sha256-VFZE5ZQQ6bf5n2Cf/DP1Ulcd6BLQ3rXiA1nAmJHpbzg=")
    ##(manjaroArmPatch"0021-media-rockchip-rga-do-proper-error-checking-in-probe.patch" "sha256-4YazannAvdOvG5RnuRudp7BZSdNjEQRidmC9LPFt9os=")
    ##(manjaroArmPatch"0024-Bluetooth-btsdio-Do-not-bind-to-non-removable-BCM4345-and-BCM43455.patch" "0n9645w3ywx3zi9dixg7957j380b6bpadvv0j0m9l4pskmarm794")
    ##(manjaroArmPatch"0025-usb-typec-fusb302-fix-masking-of-comparator.patch" "0r4mfjb3ygskw242xch0m4iz876w9yv7bjxh6fk1wq8xqxy6a0za")
    #(manjaroArmPatch"0001-Bluetooth-Add-new-quirk-for-broken-local-ext-features.patch" "sha256-CExhJuUWivegxPdnzKINEsKrMFx/m/1kOZFmlZ2SEOc=")
    ##(megousPatch"520e74f92e259b19052de879d08575155a91055b" "0sngyj7qww9bhra1kg5h68fisrhfkjdfgkzgsp00d75ww5sqlfxs")

    (manjaroArmPatch
      "1001-arm64-dts-allwinner-add-hdmi-sound-to-pine-devices.patch"            # A64-based devices
      "sha256-DApd791A+AxB28Ven/MVAyuyVphdo8KQDx8O7oxVPnc=")

    (manjaroArmPatch
      "1002-arm64-dts-allwinner-add-ohci-ehci-to-h5-nanopi.patch"                # Nanopi Neo Plus 2
      "sha256-9NmgoYYdB50vWFOGhvtCWkOrI+Ey3M0af2zrT9fsPjg=")

    (manjaroArmPatch
      "1003-drm-bridge-analogix_dp-Add-enable_psr-param.patch"                   # Pinebook Pro;  From list: https://patchwork.kernel.org/project/dri-devel/patch/20200626033023.24214-2-shawn@anastas.io/
      "sha256-W4o4Qa4f625SMcl6NCfeXHlWnYIceYdbEQGlHLET+Sg=")

    (manjaroArmPatch
      "1005-panfrost-Silence-Panfrost-gem-shrinker-loggin.patch"                 # Panfrost
      "sha256-bw3+erGlxJfbLwtifLfyd6zT5dCXXAYkoWNk52xjQzI=")

    (manjaroArmPatch
      "1007-drm-rockchip-add-support-for-modeline-32MHz-e.patch"                 # DP Alt Mode
      "sha256-npGwg0fqJUUPaoyhhwlswvzdcAab4PELLUTKBTbkoXw=")

    (manjaroArmPatch
      "1008-rk3399-rp64-pcie-Reimplement-rockchip-PCIe-bus-scan-delay.patch"     # RockPro64
      "sha256-6c64k47hnuKL+A+QjDBPSgT1dwTUlIjbhHGhwGZk7xI=")

    #(manjaroArmPatch
    #  "1009-drm-meson-encoder-add-YUV422-output-support.patch"                   # Meson G12B
    #  "sha256-Nyw+cjiBqp0c9eMFB0mmNCVa+uDYHsPs/j+CwLIdEDk=")

    (manjaroArmPatch
      "1011-arm64-dts-amlogic-add-meson-g12b-ugoos-am6-plus.patch"               # Meson Ugoos
      "sha256-4YoT5pK70aG7EZBghn47JbFqq0qCl1iVUgWMQV223Ec=")

    #(manjaroArmPatch
    #  "1012-drm-panfrost-scheduler-improvements.patch"                           # Panfrost;  Will be submitted upstream by the author
    #  "sha256-wE7xNwBcQ6OIqe97IAbpas73m+3qN03V/+Cp0MMuuEM=")

    (manjaroArmPatch
      "1013-arm64-dts-rockchip-Add-PCIe-bus-scan-delay-to-RockPr.patch"          # RockPro64
      "sha256-1ziyiNpGDpxsHZH9TJozwxv1ryWFi9stdPu27OCZau8=")

    (manjaroArmPatch
      "1014-drm-rockchip-support-gamma-control-on-RK3399.patch"                  # RK3399 VOP;  From list: https://patchwork.kernel.org/project/linux-arm-kernel/cover/20211019215843.42718-1-sigmaris@gmail.com/
      "sha256-VFZE5ZQQ6bf5n2Cf/DP1Ulcd6BLQ3rXiA1nAmJHpbzg=")

#    (manjaroArmPatch
#        "2001-Bluetooth-Add-new-quirk-for-broken-local-ext-features.patch"         # Bluetooth;  From list: https://patchwork.kernel.org/project/bluetooth/patch/20200705195110.405139-2-anarsoul@gmail.com/
#      "sha256-CExhJuUWivegxPdnzKINEsKrMFx/m/1kOZFmlZ2SEOc=")

#    (manjaroArmPatch
#        "2002-Bluetooth-btrtl-add-support-for-the-RTL8723CS.patch"                 # Bluetooth;  From list: https://patchwork.kernel.org/project/bluetooth/patch/20200705195110.405139-3-anarsoul@gmail.com/
#      "sha256-dDdvOphTcP/Aog93HyH+L9m55laTgtjndPSE4/rnzUA=")

    (manjaroArmPatch
        "2003-arm64-allwinner-a64-enable-Bluetooth-On-Pinebook.patch"              # Bluetooth;  From list: https://patchwork.kernel.org/project/bluetooth/patch/20200705195110.405139-4-anarsoul@gmail.com/
      "sha256-WW4aEiXr0SabLg5GN0AmouQRSZbdDn5CiINHfwh3MgU=")

    (manjaroArmPatch
        "2004-arm64-dts-allwinner-enable-bluetooth-pinetab-pinepho.patch"          # Bluetooth;  The PinePhone part is in linux-next
      "sha256-o43P3WzXyHK1PF+Kdter4asuyGAEKO6wf5ixcco2kCQ=")

#    (manjaroArmPatch
#        "2005-staging-add-rtl8723cs-driver.patch"                                  # Realtek WiFi;  Not upstreamable
#      "sha256-6ywm3dQQ5JYl60CLKarxlSUukwi4QzqctCj3tVgzFbo=")

    (manjaroArmPatch
        "2008-brcmfmac-USB-probing-provides-no-board-type.patch"                   # Bluetooth;  Will be submitted upstream by the author
      "sha256-UnQzevvr5SaLcMvMx+2An4hKuIz6FtsKmPzsgh88tPI=")

    (manjaroArmPatch
        "2009-arm64-dts-rockchip-Work-around-daughterboard-issues.patch"           # Pinebook Pro microSD;  Will be submitted upstream by the author
      "sha256-Ypr19sJd2XuNOOM/zPch/6mhE3xPmHqkQpVIC5KMBBU=")

  ]);
})
//
(args.argsOverride or {})
