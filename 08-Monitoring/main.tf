/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  credentials = file("../cft-training.json")
  project = var.project_id
  region  = var.region
  version = "~> 3.9.0"
}

# Enable the monitoring API on the hosting project
#resource "google_project_service" "monitoring" {
#  service            = "monitoring.googleapis.com"
#  disable_on_destroy = false
#}


/* resource "google_monitoring_group" "sandbox_group" {
  display_name = "sandbox"
  filter = "metadata.user_labels.env=\"sandbox\""
} */


# Create the email notification channel first
resource "google_monitoring_notification_channel" "email" {
  display_name = "Test Notification Channel"
  project      = var.project_id 
  type         = "email"
  labels = {
    email_address = "gangcchen@google.com"
  }
}

# Create the PagerDuty notification channel first
/* resource "google_monitoring_notification_channel" "pagerduty" {
  display_name = "PagerDuty Notification Channel"
  project      = var.project_id 
  type         = "pagerduty"
  labels = {
    service_key = "your_pager_duty_service_key",
  
  }
} */

# Create alerting policy for Direct InterConnect Uptime
resource "google_monitoring_alert_policy" "alert_gbp_session" {
  display_name = "1 - BGP Session Up"
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Partner InterConnect BGP Session Up"
    condition_threshold {
      filter = "metric.type=\"router.googleapis.com/bgp/session_up\" resource.type=\"gce_router\""
      duration = "60s"
      comparison = "COMPARISON_LT"
      threshold_value = 1
      trigger {
        count = 1
      }
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_MEAN"
        //cross_series_reducer = "REDUCE_COUNT"
      } 
    }
  }
  documentation {
    content = "Number of BGP sessions are less than expected. Indicating GCP session down."
  }
  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]

}


