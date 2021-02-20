local kp =
  (import 'kube-prometheus/main.libsonnet') + {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
    },
  };

local manifests_setup =
  { '0namespace-namespace': kp.kubePrometheus.namespace } +
  { ['prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator)) };

local manifests_node_exporter =
  { [name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) };

local manifests_blackbox_exporter =
  { [name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) };

local manifests_kube_state_metrics =
  { [name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) };

local manifests_alertmanager =
  { [name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) };

local manifests_prometheus =
  { [name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) };

local manifests_prometheus_adapter =
  { [name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) };

local manifests_grafana =
  { [name]: kp.grafana[name] for name in std.objectFields(kp.grafana) };

local manifests_kubernetes = 
  { [name]: kp.kubernetesMixin[name] for name in std.objectFields(kp.kubernetesMixin) };

local manifests =
  // Uncomment line below to enable vertical auto scaling of kube-state-metrics
  //{ ['ksm-autoscaler-' + name]: kp.ksmAutoscaler[name] for name in std.objectFields(kp.ksmAutoscaler) } +
  // serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
  { 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
  { ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator)) } +
  { 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
  { 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
  { 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
  { ['node-exporter/' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
  { ['blackbox-exporter/' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
  { ['kube-state-metrics/' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
  { ['alertmanager/' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
  { ['prometheus/' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
  { ['prometheus-adapter/' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
  { ['grafana/' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
  { ['kubernetes/' + name]: kp.kubernetesMixin[name] for name in std.objectFields(kp.kubernetesMixin) };

local kustomizationResourceFile(name) = './manifests/' + name + '.yaml';
local kustomizationResourceFileFolder(name) = '' + name + '.yaml';
local kustomization = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFile, std.objectFields(manifests)),
};

local kustomization_setup = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_setup)),
};

local kustomization_node_exporter = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_node_exporter)),
};

local kustomization_blackbox_exporter = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_blackbox_exporter)),
};

local kustomization_kube_state_metrics = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_kube_state_metrics)),
};

local kustomization_alertmanager = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_alertmanager)),
};

local kustomization_prometheus = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_prometheus)),
};

local kustomization_prometheus_adapter = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_prometheus_adapter)),
};

local kustomization_grafana = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_grafana)),
};

local kustomization_kubernetes = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFileFolder, std.objectFields(manifests_kubernetes)),
};

manifests {
  '../kustomization': kustomization,
  'setup/kustomization': kustomization_setup,
  'node-exporter/kustomization': kustomization_node_exporter,
  'blackbox-exporter/kustomization': kustomization_blackbox_exporter,
  'kube-state-metrics/kustomization': kustomization_kube_state_metrics,
  'alertmanager/kustomization': kustomization_alertmanager,
  'prometheus/kustomization': kustomization_prometheus,
  'prometheus-adapter/kustomization': kustomization_prometheus_adapter,
  'grafana/kustomization': kustomization_grafana,
  'kubernetes/kustomization': kustomization_kubernetes
}
