# OpenTofu MCP Examples

This file contains examples of how to use the OpenTofu MCP (Model Context Protocol) server functions.

## 1. Search Registry

Search for providers, modules, resources, and data sources:

```
mcp__opentofu__search-opentofu-registry
- query: "aws" (search for AWS-related items)
- type: "provider" | "module" | "resource" | "data-source" | "all"
```

## 2. Get Provider Details

Get detailed information about a specific provider:

```
mcp__opentofu__get-provider-details
- namespace: "hashicorp"
- name: "aws" (without terraform-provider- prefix)
```

## 3. Get Module Details

Get detailed information about a specific module:

```
mcp__opentofu__get-module-details
- namespace: "terraform-aws-modules"
- name: "vpc" (without terraform-aws- prefix)
- target: "aws"
```

## 4. Get Resource Documentation

Get documentation for a specific resource:

```
mcp__opentofu__get-resource-docs
- namespace: "hashicorp"
- name: "aws"
- resource: "s3_bucket" (without provider prefix)
- version: "v5.0.0" (optional)
```

## 5. Get Data Source Documentation

Get documentation for a specific data source:

```
mcp__opentofu__get-datasource-docs
- namespace: "hashicorp"
- name: "aws"
- dataSource: "ami" (without provider prefix)
- version: "v5.0.0" (optional)
```

## Common Use Cases

1. **Finding AWS Resources**: Search for "s3", "ec2", "lambda" to find relevant resources
2. **Module Discovery**: Search for modules like "vpc", "security-group", "rds"
3. **Documentation Lookup**: Get detailed docs for specific resources you're using
4. **Version Information**: Check available versions and compatibility

## Tips

- Don't include prefixes like "terraform-provider-" or "terraform-aws-" in names
- Use simple terms in searches (e.g., "database" instead of "terraform-aws-rds")
- Provider namespace is usually the organization name (hashicorp, aws, etc.)
