terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

variable "namespace" {
  type = string
}

variable "postgresql-password" {
  type = string
}

variable "postgresql-database" {
  type = string
}

variable "postgresql-user" {
  type = string
}

variable "graphile-password" {
  type = string
}

locals {
  react-app-graphql-uri = "backend.${var.namespace}.svc.cluster.local:4000"
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace = var.namespace
  create_namespace = true
  
  values = [
	  <<EOB
      global:
        postgresql:
          postgresqlPassword: ${var.postgresql-password}
          postgresqlDatabase: ${var.postgresql-database}
          postgresqlUsername: ${var.postgresql-user}
      initdbScripts:
        initial.sh: |
          ${file("../services/database-migration/initial.sh")} 
      extraEnv:
        GRAPHILE_PASSWORD: ${var.graphile-password}
	  EOB
  ]
}

data "kubectl_path_documents" "manifests" {
    pattern = "../services/*/k8s.yml"
    vars = {
      namespace = var.namespace
      postgresql-user = var.postgresql-user
      postgresql-password = var.postgresql-password
      postgresql-database = var.postgresql-database
      graphile-password = var.graphile-password
      react-app-graphql-uri = local.react-app-graphql-uri
    }
}

resource "kubectl_manifest" "services" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
}