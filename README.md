# CaféNorte - Data Solution Pipeline

[![Python Version](https://img.shields.io/badge/python-3.13%2B-blue.svg)](https://www.python.org/)
[![Package Manager](https://img.shields.io/badge/uv-managed-purple.svg)](https://github.com/astral-sh/uv)

Pipeline analítico de ingeniería de datos diseñado para **CaféNorte**. Solución que ingiere, limpia, consolida y modela datos heterogéneos provenientes de tres sistemas origen (POS Tiendas Físicas en CSV, ERP Inventarios en JSON y Shopify E-Commerce en Parquet) hacia una base de datos analítica centralizada en PostgreSQL.

## 🚀 Requisitos Previos e Instalación

Este proyecto utiliza [**`uv`**](https://github.com/astral-sh/uv) como gestor ultrarrápido de paquetes y entornos virtuales de Python.

### 1. Instalación de `uv`
Si no tienes `uv` instalado, puedes instalarlo ejecutando:

```bash
# macOS / Linux
curl -sSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Clonar el repositorio y sincronizar el entorno
`uv` descargará e instalará automáticamente Python 3.13+ y todas las dependencias requeridas en un entorno virtual aislado:

```bash
git clone <URL_DEL_REPOSITORIO>
cd cafenorte-data-solution

# Sincronizar e instalar todas las dependencias principales y de desarrollo
uv sync --all-groups
```

---

## 📦 Dependencias del Proyecto

El proyecto está configurado bajo la especificación moderna de `pyproject.toml` con las siguientes librerías clave:

### Dependencias Principales (`dependencies`):
* **`polars` (`>=1.44.1`)**: Motor principal de procesamiento de datos en memoria (alto rendimiento y bajo consumo).
* **`adbc-driver-manager` (`>=1.12.0`)**: Conector ADBC (Arrow Database Connectivity) para cargas masivas de ultra alta velocidad hacia PostgreSQL.
* **`pyarrow` (`>=25.0.1`)**: Manejo e interoperabilidad de formatos en memoria y lectura eficiente de archivos `.parquet`.
* **`pandas` (`>=3.0.5`)**: Soporte complementario para manipulación de tablas.
* **`fastexcel` (`>=0.21.0`)**: Lectura y exportación eficiente de reportes Excel.

### Grupo de Desarrollo (`dev`):
* **`ipykernel` (`>=7.3.0`)**: Kernel interactivo para análisis y prototipado mediante Jupyter Notebooks.

---

## 🛠️ Herramientas de Consola y Ejecución

### Ejecución de herramientas `dbc` con `uv`
Para ejecutar utilidades o herramientas de base de datos/interfaz mediante la suite `dbc` a través del gestor de herramientas globales de `uv`, utiliza:

```bash
uv tool run dbc <comando_o_parametro>
```

---

## 🏃‍♂️ Cómo Iniciar y Ejecutar el Pipeline


### Entorno Interactivo / Jupyter
Necesitas explorar las transformaciones interactivamente en un Notebook de Jupyter instalando las extensiones correspondientes en VSCode

---

## ⚙️ Configuración de la Base de Datos

Asegúrate de contar con una instancia de **PostgreSQL** (local o en Amazon RDS) configurada con las credenciales de acceso en las variables de entorno o archivo de configuración `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cafenorte_dw
DB_USER=postgres
DB_PASSWORD=tu_password
```
