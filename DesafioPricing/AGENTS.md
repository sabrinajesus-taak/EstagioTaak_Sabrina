# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**DesafioPricing** is a Salesforce DX project implementing an order management and pricing system with Lightning Web Components (LWC) frontend and Apex backend. It includes order processing, pricing calculations, API integrations, and custom Salesforce objects.

## Development Commands

### Testing
- `npm run test` or `npm test` — Run all unit tests (both LWC and Apex tests)
- `npm run test:unit` — Run LWC unit tests via sfdx-lwc-jest
- `npm run test:unit:watch` — Run tests in watch mode for continuous development
- `npm run test:unit:debug` — Run tests with debugger enabled
- `npm run test:unit:coverage` — Generate coverage report for unit tests

### Code Quality
- `npm run lint` — Lint Aura and LWC JavaScript files (uses ESLint with @salesforce/eslint-config-lwc)
- `npm run prettier` — Format all code files (Apex, LWC, CSS, HTML, JSON, YAML, XML, etc.)
- `npm run prettier:verify` — Check if files meet formatting standards without modifying them

### Deployment
- `sf project deploy start --manifest path/to/package.xml` — Deploy metadata to org
- `sf org create scratch --definition-file config/project-scratch-def.json` — Create a scratch org

## Project Architecture

### Directory Structure

```
force-app/main/default/
├── classes/                    # Apex classes
│   ├── API/                    # API integration layer
│   │   ├── Batch 1/            # Scheduled batch jobs
│   │   ├── DTO/                # Data transfer objects
│   │   ├── Factory/            # Factory patterns for object creation
│   │   ├── Inbound/            # Inbound API handlers
│   │   ├── Outbound/           # Outbound API handlers
│   │   ├── Logs/               # Integration logging
│   │   ├── Utils/              # Utility functions
│   │   └── Test/               # API integration tests
│   ├── Domains/                # Business logic by domain
│   │   ├── Order/              # Order-related logic
│   │   ├── OrdemItem/          # Order item logic
│   │   └── TriggerHandler/     # Base trigger handler pattern
│   ├── Services/               # Service layer
│   ├── Selectors/              # SOQL query objects
│   ├── FaqController/          # FAQ component controller
│   ├── orderLWC/               # Order wizard LWC controller
│   ├── Utils/                  # Shared utilities
│   └── triggers/               # Trigger definitions
├── lwc/                        # Lightning Web Components
│   ├── orderWizard/            # Multi-step order creation wizard
│   ├── faq/                    # FAQ component
│   └── buttonIntegration/      # Integration button component
└── objects/                    # Custom object metadata
```

### Key Architectural Patterns

1. **Trigger Handler Pattern** — Uses a base `TriggerHandler` class for all triggers. Triggers (Order, OrderItem) delegate to handler classes (OrderHandler, OrdemItemHandler) that override virtual methods like `beforeInsert()`, `afterUpdate()`, etc. Handlers can be bypassed individually or globally using static methods.

2. **Service/Selector Layer** — Business logic is separated into Services (processes) and Selectors (queries). Controllers call these layers rather than containing logic directly.

3. **API Integration** — Organized into Inbound (receiving data), Outbound (sending data), Batch (scheduled jobs), and Logs (tracking). Uses DTO objects for data transformation.

4. **LWC Components** — Components follow the Salesforce LWC architecture. Controllers (Apex classes marked with `@AuraEnabled`) expose methods to components. Use `@AuraEnabled(cacheable=true)` for read-only operations.

### Metadata and Objects

Custom objects include:
- **Order** — Standard Salesforce Order object with enhancements
- **City__c** — City reference data
- **Tax__c** — Tax rate definitions
- **Margem__c** — Margin/pricing configuration
- **IntegrationLog__c** — Tracks inbound/outbound API calls for debugging
- **AccountAdd__c** — Account address details

## Code Organization Guidelines

### Apex Classes
- Organize new code into the appropriate domain folder (e.g., `classes/Domains/Order/`)
- Use services for cross-cutting business logic
- Use selectors for all SOQL queries (centralize query logic)
- Test classes go in domain folders with a "Test" suffix (e.g., `OrderHandlerTest`, `IntegrationInboudOrderTest`)

### Lightning Web Components
- Each component is a folder under `lwc/` containing: `<componentName>.js`, `<componentName>.html`, `<componentName>.css`, and `<componentName>.js-meta.xml`
- Import Apex methods with `@salesforce/apex/ClassName.methodName`
- Use `@track` for reactive properties
- Test files follow the naming pattern `<componentName>.test.js`

### Test Writing
- **Apex Tests** — Use `@isTest` classes. The `TestFactorySObject` utility helps create test data.
- **LWC Tests** — Use sfdx-lwc-jest (Jest-based). Test files import components and mock Apex calls.
- Run a single test file: `npm run test:unit -- path/to/component.test.js`

## Configuration Files

- **sfdx-project.json** — Defines package directories and Salesforce API version (currently 66.0)
- **package.json** — Dependencies, scripts, and lint-staged configuration for pre-commit hooks
- **.prettierrc** (implicit defaults) — Uses Prettier 3.5.3 with support for Apex, XML, and LWC formatting
- **config/project-scratch-def.json** — Scratch org definition for local development

# Preferências de comunicação

- Responda sempre em português do Brasil.
- Explique conceitos técnicos de forma didática.
- Utilize termos em inglês apenas quando forem nomes de tecnologias, comandos ou conceitos que não possuem uma tradução comum.

# Como trabalhar comigo

- Sempre explique o plano antes de fazer alterações no código.
- Aguarde minha aprovação antes de modificar arquivos.
- Faça o mínimo de alterações necessárias.
- Ensine o motivo das mudanças propostas.
- Prefira me ensinar como implementar as soluções em vez de apenas entregar o código pronto.

# Projeto

- Este é um projeto Salesforce utilizando LWC e Apex.