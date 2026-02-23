# Thomas Wiebe Home Assistant Add-ons

A collection of Home Assistant OS add-ons.

## Installation

Click the button below to add this repository to your Home Assistant instance:

[![Add repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftwiebe%2Fhassos-addons)

Or add it manually: go to **Settings → Add-ons → Add-on Store**, open the overflow menu (⋮) in the top right, choose **Repositories**, and paste in the URL:

```
https://github.com/twiebe/hassos-addons
```

## Add-ons

### [Vector](vector/README.md)

[Vector](https://vector.dev) is a high-performance observability data pipeline. This add-on runs Vector as a Home Assistant OS service, collecting logs from the systemd journal and forwarding them to a configured sink.

Supported sinks:
- [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/)
- [Loki](https://grafana.com/oss/loki/) (including Grafana Cloud)
