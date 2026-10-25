## 0.8.0

- Bump vector to 0.60.0
- Update hassio-addons base image to v9.5.1

## 0.7.0

- Bump vector to 0.59.0

## 0.6.0

- Bump vector to 0.58.0
- Removed `dangerously_allow_unconfined_template_resolution` again, as 0.58.0 no longer requires it for dynamic labels. No config or behaviour change
  for users.
- **Breaking:** Sink endpoint URLs now require an explicit `http://` or `https://` scheme - the addon fails to start with an error in the log if the scheme is missing. A scheme-less endpoint was previously accepted (though the documentation already called for a full URL); Vector 0.58 changed the assumed default from `http://` to `https://`, so the addon now rejects the ambiguous form instead of silently picking a scheme.

## 0.5.0

- Bump vector to 0.57.0
- Enable `dangerously_allow_unconfined_template_resolution` to preserve loki labeling

## 0.4.0

- Bump vector to 0.56.0
- Accept both relative and absolute paths as `override_config_path`
- Be clearer on where to put `vector.yaml` for advanced configuration. The previous default value of `/config/vector.yaml` was misleading. ([#12](https://github.com/twiebe/hassos-addons-vector/issues/12))

## 0.3.0

- Bump vector to 0.55.0

## 0.2.0

- Bump vector to 0.54.0

## 0.1.0

- Initial release supporting VictoriaLogs and Loki
