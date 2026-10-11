![SAP S/4HANA](https://img.shields.io/badge/SAP_S%2F4HANA-2023-0A6ED1?logo=sap\&logoColor=white)
![ABAP RAP](https://img.shields.io/badge/ABAP-RAP-0A6ED1?logo=sap\&logoColor=white)
![ABAP CDS](https://img.shields.io/badge/ABAP-CDS-0A6ED1?logo=sap\&logoColor=white)
![OData V4](https://img.shields.io/badge/OData-V4-008000)
![SAP Fiori Elements](https://img.shields.io/badge/SAP-Fiori_Elements-0A6ED1?logo=sap\&logoColor=white)
![abapGit](https://img.shields.io/badge/Version_Control-abapGit-orange)
![GitHub](https://img.shields.io/badge/Repository-GitHub-181717?logo=github\&logoColor=white)


# SAP Ordem de Venda RAP

Aplicação empresarial para gerenciamento de **Ordens de Venda**, desenvolvida utilizando o **SAP ABAP RESTful Application Programming Model (RAP)**, **ABAP CDS**, **OData V4** e **SAP Fiori Elements**.

A solução implementa um Business Object transacional para gerenciamento de ordens e seus respectivos itens, incluindo regras de negócio, validações, cálculos automáticos, controle de status, Draft e Actions.

---

## Overview

A aplicação utiliza a arquitetura moderna de desenvolvimento SAP, mantendo o modelo de dados, comportamento transacional e exposição de serviços organizados em camadas.

As regras de negócio são processadas no backend ABAP/RAP, enquanto a interface é disponibilizada através do SAP Fiori Elements utilizando o modelo orientado a metadados.

### Principais capacidades

* Gerenciamento de Ordens de Venda
* Gerenciamento de itens da ordem
* Managed Business Object
* Draft
* Early Numbering
* Determinations
* Validations
* Actions
* Side Effects
* EML
* Cálculo automático de valores
* Atualização automática do total da ordem
* Controle de status
* Value Help de clientes
* OData V4
* SAP Fiori Elements

---

## Architecture

```
┌──────────────────────────────────────────────┐
│              SAP Fiori Elements              │
└──────────────────────┬───────────────────────┘
                       │
                       │ OData V4
                       ▼
┌──────────────────────────────────────────────┐
│              Service Binding                 │
│                 ZUI_OV_O4                    │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│             Service Definition               │
│                   ZUI_OV                     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│             Projection Layer                 │
│        Z_C_OVCAB / Z_C_OVITEM                │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│          Behavior Definition                 │
│             RAP Business Object              │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│       Behavior Implementation                │
│              ZBP_I_OVCAB                     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│              Interface CDS                  │
│       Z_I_OVCAB / Z_I_OVITEM                 │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                 Persistence                 │
│            ZOVCAB / ZOVITEM                  │
└──────────────────────────────────────────────┘
```

---

## Business Object

O Business Object principal é representado pela entidade raiz:

`Z_I_OVCAB`

A ordem possui uma relação de composição com seus itens:

```text
Z_I_OVCAB
    │
    └── _Item
          │
          └── Z_I_OVITEM
```

A composição permite tratar o cabeçalho e seus itens como uma unidade transacional dentro do RAP.

---

## Business Flow

O fluxo principal da aplicação é:

```text
Criar Ordem
     │
     ▼
Informar Cliente
     │
     ▼
Adicionar Itens
     │
     ▼
Informar Quantidade e Preço
     │
     ▼
Calcular Total dos Itens
     │
     ▼
Atualizar Total da Ordem
     │
     ▼
Validar Dados
     │
     ▼
Fornecer Ordem
     │
     ▼
Atualizar Status
```

---

## CDS Data Model

A aplicação utiliza diferentes camadas de CDS para separar o modelo de dados interno do modelo exposto pela aplicação.

### Interface Views

| CDS              | Responsabilidade                   |
| ---------------- | ---------------------------------- |
| `Z_I_OVCAB`      | Entidade raiz / cabeçalho da ordem |
| `Z_I_OVITEM`     | Itens da ordem                     |
| `Z_I_CLIENTE_VH` | Value Help de clientes             |

### Projection Views

| CDS          | Responsabilidade      |
| ------------ | --------------------- |
| `Z_C_OVCAB`  | Projeção do cabeçalho |
| `Z_C_OVITEM` | Projeção dos itens    |

A separação entre Interface View e Projection View permite controlar o modelo exposto pela aplicação sem acoplar diretamente a camada de consumo ao modelo interno.

---

## RAP Behavior

O comportamento transacional é implementado através das Behavior Definitions e da classe:

`ZBP_I_OVCAB`

### Standard Operations

* Create
* Update
* Delete

### Early Numbering

O número da ordem é determinado durante a criação do Business Object utilizando **Early Numbering**.

### Determination

A aplicação utiliza Determinations para processamento automático de regras de negócio.

Um dos principais processamentos é o cálculo dos valores da ordem.

```text
Quantidade × Preço Unitário
             │
             ▼
        Valor do Item
             │
             ▼
      Soma dos Itens
             │
             ▼
       Total da Ordem
```

Alterações nos dados dos itens provocam o recálculo dos valores relacionados ao cabeçalho.

### Validation

Validações são executadas durante o processamento transacional para garantir a consistência dos dados.

A aplicação possui validação relacionada ao cliente informado na ordem, utilizando o mecanismo de mensagens do RAP.

### Action

A aplicação possui a Action:

`fornecer`

A Action realiza o processamento necessário para alteração do status da ordem.

### Status

| Código | Status    |
| ------ | --------- |
| `N`    | Novo      |
| `F`    | Fornecido |
| `B`    | Faturada  |
| `C`    | Cancelada |

A disponibilidade da Action é controlada dinamicamente de acordo com o estado atual da ordem.

---

## Side Effects

Foram utilizados **Side Effects** para atualizar informações dependentes após alterações realizadas no Business Object.

Isso permite que informações derivadas, como status e valores calculados, sejam atualizadas na interface Fiori após o processamento realizado pelo backend.

---

## Draft

O Business Object utiliza o mecanismo de **Draft** do RAP.

O Draft permite manter alterações temporariamente durante a edição antes da confirmação definitiva da transação.

Tabelas de Draft:

* `ZOVCAB_D`
* `ZOVITEM_D`

---

## Value Help

A aplicação possui uma CDS específica para disponibilizar o auxílio de pesquisa de clientes:

`Z_I_CLIENTE_VH`

A Value Help é utilizada pela interface Fiori para facilitar a seleção do cliente associado à ordem.

---

## SAP Fiori Elements

A aplicação é consumida através do **SAP Fiori Elements**, utilizando o modelo orientado a metadados.

A interface disponibiliza:

* List Report
* Object Page
* Criação de ordens
* Edição de ordens
* Gerenciamento de itens
* Actions
* Value Help
* Mensagens de validação
* Atualização de dados dependentes
* Processamento de Draft

A utilização de Fiori Elements permite que grande parte da estrutura da interface seja derivada dos metadados e do modelo transacional definido no backend.

---

## OData

O serviço da aplicação é definido através de:

`ZUI_OV`

A exposição principal utiliza:

`ZUI_OV_O4`

O Service Binding disponibiliza o Business Object através de **OData V4** para consumo pelo SAP Fiori Elements.

---

## EML

O projeto utiliza **Entity Manipulation Language (EML)** para operações sobre o Business Object RAP.

O EML permite realizar operações transacionais diretamente sobre as entidades RAP, respeitando o comportamento definido no Business Object.

---

## Technical Stack

| Tecnologia         | Utilização               |
| ------------------ | ------------------------ |
| SAP S/4HANA 2023   | Plataforma               |
| ABAP Platform 2023 | Backend                  |
| ABAP RAP           | Modelo transacional      |
| ABAP CDS           | Modelo de dados          |
| OData V4           | Exposição de serviços    |
| SAP Fiori Elements | Interface                |
| Eclipse ADT        | Desenvolvimento          |
| ABAP OO            | Implementação            |
| EML                | Manipulação transacional |
| Draft              | Controle de edição       |
| abapGit            | Versionamento            |
| GitHub             | Repositório              |

---

## Main Objects

| Objeto           | Descrição                     |
| ---------------- | ----------------------------- |
| `Z_I_OVCAB`      | CDS Interface — Cabeçalho     |
| `Z_I_OVITEM`     | CDS Interface — Item          |
| `Z_C_OVCAB`      | CDS Projection — Cabeçalho    |
| `Z_C_OVITEM`     | CDS Projection — Item         |
| `Z_I_CLIENTE_VH` | CDS Value Help — Cliente      |
| `ZBP_I_OVCAB`    | Behavior Implementation       |
| `ZUI_OV`         | Service Definition            |
| `ZUI_OV_O4`      | OData V4 Service Binding      |
| `ZOVCAB_D`       | Draft Persistence — Cabeçalho |
| `ZOVITEM_D`      | Draft Persistence — Item      |

---

## Repository Structure

Os objetos ABAP são versionados utilizando **abapGit**.

```text
sap-ordem-venda-RAP
│
├── README.md
├── .abapgit.xml
│
└── src
    ├── CDS Views
    ├── Behavior Definitions
    ├── Behavior Implementation
    ├── Service Definitions
    ├── Service Bindings
    ├── Draft Tables
    └── Supporting Objects
```

Os arquivos presentes no diretório `src` representam os objetos ABAP serializados pelo abapGit.

---

## Environment

* SAP S/4HANA 2023
* ABAP Platform 2023
* SAP Fiori for S/4HANA 2023
* Eclipse ADT

---

## Version Control

O código-fonte é versionado utilizando **Git**, com integração entre o ambiente SAP e o GitHub através do **abapGit**.

Repository:

**[github.com/WellingtonXavi/sap-ordem-venda-RAP](https://github.com/WellingtonXavi/sap-ordem-venda-RAP)**

---

## Technical Highlights

* RESTful Application Programming Model
* Managed Business Object
* Draft-enabled application
* Composition between root and child entities
* Early Numbering
* Determinations
* Validations
* Actions
* Dynamic feature control
* Side Effects
* EML
* CDS Interface / Projection architecture
* OData V4
* SAP Fiori Elements
* Metadata-driven UI
* Backend-driven business logic
* Git-based ABAP source control


## Ambiente
- SAP S/4HANA 2023
- ABAP Platform 2023
- Eclipse ADT
- SAP RAP
- OData V4
- SAP Fiori Elements

## Objetivo
Demonstrar o desenvolvimento de uma aplicação empresarial utilizando o modelo transacional RAP, incluindo cabeçalho de ordem, itens, regras de negócio, cálculos automáticos e controle de status.
