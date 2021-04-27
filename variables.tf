# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the resource name(s) for distinguishing purposes."
  type        = string
  validation {
    condition     = length(var.name_suffix) <= 14
    error_message = "A max of 14 character(s) are allowed."
  }
}

variable "vpc_network" {
  description = "A reference (self link) to the VPC network to host the cluster in."
  type        = string
}

variable "vpc_subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in."
  type        = string
}

variable "pods_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s pods."
  type        = string
}

variable "services_ip_range_name" {
  description = "Name of subnet's secondary IP range for hosting k8s services."
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "An arbitrary name to identify the k8s cluster."
  type        = string
  default     = "k8s"
}

variable "ingress_ip_names" {
  description = "Arbitrary names for list of static Ingress IPs to be created for the GKE cluster. Use empty list to avoid creating static Ingress IPs."
  type        = list(string)
  default     = []
}

variable "istio_ip_names" {
  description = "Arbitrary names for list of static Istio IPs to be created for the GKE cluster. Use empty list to avoid creating static Istio IPs."
  type        = list(string)
  default     = []
}

variable "nginx_ip_names" {
  description = "Arbitrary names for list of static NGINX IPs to be created for the GKE cluster. Use empty list to avoid creating static NGINX IPs."
  type        = list(string)
  default     = []
}

variable "firewall_name" {
  description = "An arbitrary name to identify the firewall that will be generated for the GKE cluster if \"var.istio_ip_names\" or \"var.firewall_ingress_ports\" contains any values."
  type        = string
  default     = "allow-ingress"
}

variable "firewall_ingress_ports" {
  description = "Additional ports (on cluster nodes) that should be allowed via firewall rules to receive incoming traffic."
  type        = list(string)
  default     = []
}

variable "sa_name" {
  description = "An arbitrary name to identify the ServiceAccount that will be generated & attached to the k8s cluster nodes."
  type        = string
  default     = "gke"
}

variable "gke_master_version" {
  description = "GKE version of the cluster master to be used. See https://cloud.google.com/kubernetes-engine/docs/release-notes. "
  type        = string
  default     = "1.17.17-gke.2800"
}

variable "cluster_description" {
  description = "The description of the GKE cluster."
  type        = string
  default     = "Generated by Terraform"
}

variable "cluster_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster. Both the key and the value must only contain lowercase letters ([a-z]), numeric characters ([0-9]), underscores (_) and dashes (-). International characters are allowed."
  type        = map(string)
  default     = {}
}

variable "location_type" {
  description = "Options are \"ZONAL\" (default) or \"REGIONAL\". In \"ZONAL\" clusters, the control-plane exists in a single zone. In \"REGIONAL\" clusters, the control-plane is replicated across multiple zones. Regional clusters contain additional quotas. See \"var.locations\". See https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability."
  type        = string
  default     = "ZONAL"
}

variable "locations" {
  description = "Accepts a list of one or more zone-letters from among \"a\", \"b\", \"c\" or \"d\". Defaults to a single \"a\" zone if nothing is specified here. If \"var.location_type\" is \"ZONAL\", then multiple values can be passed here to make it a \"multi-zonal\" cluster - in which case the control-plane will run in the first specified zone while nodes are replicated in all specified zones.. If \"var.location_type\" is \"REGIONAL\" then the control-plane and the nodes are all replicated in all specified zones. See https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters"
  type        = list(string)
  default     = ["a"]
}

variable "master_authorized_networks" {
  description = "External networks that can access the cluster master(s) through HTTPS."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_public_endpoint" {
  description = "Allows access through the public endpoint of cluster master. Keep it 'true' if you have 'master_authorized_networks_config.cidr_blocks' in the k8s cluster."
  type        = bool
  default     = true
}

variable "namespaces" {
  description = "A list of namespaces to be created in kubernetes. A map of secrets can be included e.g. {\"mysql\": {\"username\": \"johndoe\", \"password\": \"password123\"}}"
  type = list(object({
    name    = string
    labels  = map(string)
    secrets = map(map(string))
  }))
  default = []
}

variable "enable_addon_http_load_balancing" {
  description = "Whether to enable HTTP (L7) load balancing controller addon."
  type        = bool
  default     = true
}

variable "enable_addon_horizontal_pod_autoscaling" {
  description = "Whether to enable Horizontal Pod Autoscaling addon which autoscales based on usage of pods."
  type        = bool
  default     = true
}

variable "max_surge" {
  description = "Max number of node(s) that can be over-provisioned while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Max number of node(s) that can be allowed to be unavailable while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously."
  type        = number
  default     = 0
}

variable "node_pools" {
  description = "\"node_pool_name\". An arbitrary name to identify the GKE node pool and its VMs & VM instance groups.\n\n\"node_count_initial_per_zone\" - immutable. It is the initial number of nodes (per zone) for the node pool to begin with. Should only be used during creation time as it is immutable - modifying it later will force a recreation of the existing node_pool. Use \"node_count_current_per_zone\" instead to modify current size after creation (if necessary).\n\n\"node_count_current_per_zone\" - mutable. It must be \"null\" when creating the cluster for the first time. It is mutable - can be changed later to modify the current number of nodes (per zone) as long as the value is between \"node_count_min_per_zone\" and \"node_count_max_per_zone\" (inclusive). If you must set the number of nodes upon initial creation, then use \"node_count_initial_per_zone\" instead which is an immutable value. Do not modify the value of \"node_count_current_per_zone\" WHILE modifying  \"node_count_min_per_zone\" or \"node_count_max_per_zone\". Run 2 separate 'terraform apply' commands to modify \"node_count_min_per_zone\"/\"node_count_max_per_zone\" in one command and modify \"node_count_current_per_zone\" in another command.\n\n\"node_count_min_per_zone\". The minimum number of nodes (per zone) this nodepool will allocate if auto-down-scaling occurs.\n\n\"node_count_max_per_zone\". The maximum number of nodes (per zone) this nodepool will allocate if auto-up-scaling occurs.\n\n\"node_labels\". Kubernetes labels (key-value pairs) to be applied to each node. The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#labels.\n\n\"max_pods_per_node\". The maximum number of pods per node in this node pool. This value has direct correlation with the IP range sizes availble in \"var.pods_ip_range_name\". See https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr.\n\n\"machine_type\". The size of VM for each node. See https://cloud.google.com/compute/docs/machine-types.\n\n\"disk_type\". Type of the disk for each node. It can also be `pd-ssd`, which is more costly.\n\n\"disk_size_gb\". Size of the disk on each node in Giga Bytes.\n\n\"preemptible\". Preemptible nodes last a maximum of 24 hours and helps reduce while providing no availability guarantee. It is like spot instances in AWS EC2.\n\n\"max_surge\". Max number of node(s) that can be over-provisioned while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously.\n\n\"max_unavailable\". Max number of node(s) that can be allowed to be unavailable while the GKE cluster is undergoing a version upgrade. Raising the number would allow more number of node(s) to be upgraded simultaneously.\n\n\"enable_shielded_nodes\". Whether to enable/disable the Secure Boot & Integrity Monitoring features of the nodes. By default (when set to null), Integrity Monitoring is set to 'true' and Secure Boot is set to 'false'."
  type = list(object({
    node_pool_name              = string
    node_count_initial_per_zone = number
    node_count_current_per_zone = number
    node_count_min_per_zone     = number
    node_count_max_per_zone     = number
    node_labels                 = map(string)
    max_pods_per_node           = number
    machine_type                = string
    disk_type                   = string
    disk_size_gb                = number
    preemptible                 = bool
    max_surge                   = number
    max_unavailable             = number
    enable_shielded_nodes       = bool
  }))
  default = [{
    node_pool_name              = "gkenp-a"
    node_count_initial_per_zone = 1
    node_count_current_per_zone = null
    node_count_min_per_zone     = 1
    node_count_max_per_zone     = 2
    node_labels                 = {}
    max_pods_per_node           = 32
    machine_type                = "e2-micro"
    disk_type                   = "pd-standard"
    disk_size_gb                = 50
    preemptible                 = false
    max_surge                   = 1
    max_unavailable             = 0
    enable_shielded_nodes       = null
  }]
}

variable "cluster_logging_service" {
  description = "The logging service to be used by the GKE cluster."
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "cluster_monitoring_service" {
  description = "The monitoring service to be used by the GKE cluster."
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "cluster_timeout" {
  description = "how long a cluster operation is allowed to take before being considered a failure."
  type        = string
  default     = "60m"
}

variable "node_pool_timeout" {
  description = "how long a node pool operation is allowed to take before being considered a failure."
  type        = string
  default     = "30m"
}

variable "namespace_timeout" {
  description = "how long a k8s namespace operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}

variable "sa_roles" {
  description = "The IAM roles that should be granted to the ServiceAccount which is attached to the GKE node VMs. This will enable the node VMs to access other GCP resources as permitted (or disallowed) by the IAM roles."
  type        = list(string)
  default     = []
}

variable "ip_address_timeout" {
  description = "how long a Compute Address operation is allowed to take before being considered a failure."
  type        = string
  default     = "5m"
}
