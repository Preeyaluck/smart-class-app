{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    useLocalCanvasKit: true,
    canvasKitBaseUrl: "canvaskit/"
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});
