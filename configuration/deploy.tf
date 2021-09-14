terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "new-moon-technologies"

    workspaces {
      name = "full-stack-template"
    }
  }
}

provider "kubectl" {
  config_path = var.kubeconfig 
}

provider "kubernetes" {
  config_path = var.kubeconfig 
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig 
  }
}

variable "namespace" {
  type = string
}

variable "app-name" {
  type = string
}

variable "image-name-base" {
  type = string
}

variable "image-tag" {
  type = string
}

variable "kubeconfig" {
  type = string
  default = "~/.kube/config"
}

resource "random_password" "default-postgresql-password" {
  length           = 16
  special          = true
}

resource "random_password" "default-graphile-password" {
  length           = 16
  special          = true
}

locals {
  react-app-graphql-uri = "backend.${var.namespace}.svc.cluster.local:4000"
  graphile-password = random_password.default-graphile-password
  postgresql-user = "postgres"
  postgresql-database = "postgres"
  postgresql-password = random_password.postgresql-password
}

resource "kubernetes_namespace" "app-namespace" {
  metadata {
    name = var.namespace 
  }
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace = var.namespace
  
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
      app-name = var.app-name
      namespace = var.namespace
      image-tag = var.image-tag
      image-name-base = var.image-name-base
      postgresql-user = local.postgresql-user
      postgresql-password = local.postgresql-password
      postgresql-database = local.postgresql-database
      graphile-password = local.graphile-password
      react-app-graphql-uri = local.react-app-graphql-uri
    }
}

resource "kubectl_manifest" "services" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
}