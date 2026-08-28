# AI_LOG.md: Bitácora de Uso de Inteligencia Artificial

---

## 1. Herramientas Utilizadas

* **Modelo de Lenguaje (LLM):** Asistente IA (ChatGPT / Claude vía interfaz conversacional).
* **Entorno de Ejecución:** Entorno interactivo de comandos Python (Data Science Interpreter) para generación e inspección directa de archivos en el repositorio (`.md`).

---

## 2. Flujo de Trabajo y Orquestación

El desarrollo de la solución se estructuró mediante una **interacción conversacional iterativa orientada por el usuario**, abarcando las siguientes etapas:

1. **Definición de Modelo de Datos:** Consulta y validación de buenas prácticas para el modelado en PostgreSQL (uso de claves sustitutas `BIGINT` frente a claves alfanuméricas).
2. **Reglas de Integridad Referencial:** Definición e implementación de restricciones `FOREIGN KEY` (`ON DELETE RESTRICT` y `ON UPDATE CASCADE`) para proteger el histórico analítico.
3. **Lógica de Carga Incremental:** Diseño del patrón de *Lookup & Upsert* en memoria con Polars (`anti-join`) e inserción idempotente en PostgreSQL (`ON CONFLICT`).
4. **Respuesta a la Prueba Técnica y Documentación:** Procesamiento de las preguntas de negocio, estructuración de la propuesta ejecutiva en AWS ($200 USD/mes máximo) y generación automatizada de los archivos `README.md` (configurado con `uv`) y la presente bitácora `AI_LOG.md`.

---

## 3. Prompts Clave e Iteración (Basados en esta Sesión)

### **Prompt 1: Claves Sustitutas Enteras vs. Códigos Alfanuméricos**
* **Prompt escrito:** 
  > *"Estoy diseñando la base de datos en PostgreSQL para unificar 3 fuentes de diferentes archivos (CSV, Parquet, JSON), cuáles son las ventajas de utilizar claves sustitutas enteras (INT/BIGINT) como llaves primarias en la tabla de hechos en lugar de mantener códigos de negocio alfanuméricos?, como ejemplos 'T001' o 'STORE-001'"*
* **Respuesta de la IA:** Explicación detallada de ventajas en eficiencia de almacenamiento, densidad en `shared_buffers`, velocidad en `JOINs`, B-Tree indexes, desacoplamiento de fuentes y compresión.
* **Acción tomada y Justificación:** **ACEPTADO.** Se adoptó el diseño de esquema en estrella utilizando `BIGINT` para la tabla de hechos `fact_ventas` y dimensiones.

---

### **Prompt 2: Configuración de Restricciones para Proteger el Histórico**
* **Prompt escrito:** 
  > *"Cómo debo configurar las restricciones FOREIGN KEY utilizando ON DELETE RESTRICT y ON UPDATE CASCADE en PostgreSQL para asegurar que las modificaciones en los catálogos no alteren el histórico de alguna tabla de hechos?"*
* **Respuesta de la IA:** DDL de ejemplo, explicación de cómo `ON DELETE RESTRICT` evita borrados accidentales de ventas y cómo `ON UPDATE CASCADE` mantiene consistencia si la PK sustituta cambia.
* **Acción tomada y Justificación:** **ACEPTADO.** Se incorporó la sintaxis DDL explícita en las tablas del modelo relacional analítico.

---

### **Prompt 3: Lógica Incremental en Python y Polars (`TIENDA_AB`)**
* **Prompt escrito:** 
  > *"No tengo un sistema de captura intermedio y proceso los datos con Python y Polars, cómo diseño la lógica para realizar cargas incrementales de modo que si llega una clave de tienda no registrada antes (ejemplo 'TIENDA_AB'), el script consulte la base de datos, genere el ID correspondiente y actualice las tablas sin duplicar registros?"*
* **Respuesta de la IA:** Código en Python/Polars utilizando `anti-join` para detectar códigos nuevos, `INSERT ... ON CONFLICT (codigo_negocio) DO NOTHING` con `psycopg`, y re-consulta para mapear los IDs a la tabla de hechos usando `adbc`.
* **Acción tomada y Justificación:** **ACEPTADO.** Se definió como el estándar oficial de ingesta incremental del proyecto.

---

### **Prompt 4: Pregunta generales acerca de herramientas o funciones de python (polars) y PostgreSQL**
* **Prompt escrito:** 
  > *"Como puedo implementar extracciones de texto múltiples para casos donde haya o no números dinámicos en diferentes posiciones..."*
* **Respuesta de la IA:** Códigos en Python/Polars utilizando como referencia documentación oficial y sugerencias de uso para diferentes casos.
* **Acción tomada y Justificación:** **ACEPTADO.** Se tomaron en cuenta sugerencias por parte del usuario y modificaciones de los códigos escritos.

---

### **Prompt 5: Documentación del README y Gestor `uv`**
* **Prompt escrito:** 
  > *"Crea un README sencillo donde indique como usar el proyecto considerando el uso de uv y dbc para la base de datos..."*
* **Respuesta de la IA:** Generación del archivo `README.md` estructurado con instrucciones de instalación de `uv`, sincronización (`uv sync`), dependencias de `pyproject.toml` y comandos `uv tool run dbc` y `uv run demo`.
* **Acción tomada y Justificación:** **ACEPTADO E IMPLEMENTADO.** Se ejecutó el script Python para escribir directamente el archivo `README.md` en el repositorio.

---

## 4. Caso Concreto de Error / Ajuste Solicitado por el Usuario

* **Caso de Error:** En respuestas acerca de código, tanto de python como postgresql, se detectaron errores mínimos en nombres de argumentos o resultados no esperados para los datos finales.
* **Corrección Aplicada:** Se descartaron algunas funciones o sugerencias reemplazandolas por similares o adecuando los nombres de los argumentos al código.
