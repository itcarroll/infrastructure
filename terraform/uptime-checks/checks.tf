# Setup local variables with list of hubs that we want checks for
locals {
  cluster_yamls = [for f in fileset(path.module, "../../config/clusters/*/cluster.yaml") : yamldecode(file(f))]
  hubs = toset(flatten([for cy in local.cluster_yamls : [for h in cy["hubs"] : {
    name       = h["name"],
    domain     = h["domain"]
    helm_chart = h["helm_chart"]
    cluster    = cy["name"]
    provider   = cy["provider"]
  }]]))
}

resource "google_monitoring_uptime_check_config" "hub_simple_uptime_check" {
  for_each = { for h in local.hubs : h.domain => h }

  display_name = "${each.value.domain} on ${each.value.cluster}"
  timeout      = "30s"

  http_check {
    # BinderHub has a different health check URL
    path           = each.value.helm_chart != "binderhub" ? "/hub/health" : "/health"
    port           = 443
    use_ssl        = true
    request_method = "GET"
    accepted_response_status_codes {
      # 200 is the only acceptable status code
      status_value = "200"
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      # This specifies the project within which the *check* exists, not where the hub exists
      project_id = var.project_id
      # This specifies the domain to check
      host = each.value.domain
    }
  }

  project = var.project_id
}

resource "google_monitoring_alert_policy" "hub_simple_uptime_alert" {
  for_each = { for h in local.hubs : h.domain => h }

  display_name = "${each.value.domain} on ${each.value.cluster}"
  combiner     = "OR"

  conditions {
    display_name = "Simple Health Check Endpoint"
    condition_threshold {
      filter          = <<-EOT
      resource.type = "uptime_url"
      AND metric.type = "monitoring.googleapis.com/uptime_check/check_passed"
      AND metric.labels.check_id = "${google_monitoring_uptime_check_config.hub_simple_uptime_check[each.key].uptime_check_id}"
      EOT
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      aggregations {
        group_by_fields = ["resource.label.host"]
        # https://cloud.google.com/monitoring/alerts/concepts-indepth#duration has
        # more info on alignment
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_NEXT_OLDER"
        # Count each failure as a "1"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
      }
    }
  }

  project = var.project_id

  # Send a notification to our PagerDuty channel when this is triggered
  notification_channels = [google_monitoring_notification_channel.pagerduty.name]
}
