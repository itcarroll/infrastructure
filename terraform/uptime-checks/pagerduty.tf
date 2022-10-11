data "sops_file" "pagerduty_integration_key" {
  # Read sops encrypted file containing integration key for pagerduty
  source_file = "secret/enc-pagerduty-service-key.secret.yaml"
}

resource "google_monitoring_notification_channel" "pagerduty" {
  project      = var.project_id
  display_name = "PagerDuty Managed JupyterHub service"
  type         = "pagerduty"
  sensitive_labels {
    service_key = data.sops_file.pagerduty_integration_key.data["pagerduty.integration_key"]
  }
}
