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
  default = "full-stack-template"
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
          postgresqlPassword: ${local.postgresql-password}
          postgresqlDatabase: ${local.postgresql-database}
          postgresqlUsername: ${local.postgresql-user}
      initdbScripts:
        initial.sh: |
          ${file("../services/database-migration/initial.sh")} 
      extraEnv:
        GRAPHILE_PASSWORD: ${local.graphile-password}
	  EOB
  ]
}

data "kubectl_path_documents" "manifests" {
    pattern = "../services/*/k8s.yml"
    vars = {
      namespace = var.namespace
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