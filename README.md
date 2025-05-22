# Plan de Despliegue para TPV_Bar

Este documento describe los pasos para desplegar la aplicación TPV_Bar en un entorno de producción. La aplicación es un sistema de Punto de Venta (POS) para bares, desarrollado en Java Swing con Hibernate para la persistencia y Ant para la compilación.

## Requisitos Previos Generales

*   **Java Development Kit (JDK):** Versión 7 o compatible para compilar.
*   **Java Runtime Environment (JRE):** Versión 7 o compatible para ejecutar en producción.
*   **Apache Ant:** Versión 1.8.0 o superior para el proceso de compilación.
*   **MySQL:** Servidor de base de datos para producción.
*   **Acceso al servidor de producción:** Para desplegar los archivos y ejecutar la aplicación.
*   **Entorno gráfico:** Necesario en la máquina de producción donde se ejecutará la interfaz de usuario Swing.

## Pasos del Plan de Despliegue

### 1. Configurar la Base de Datos de Producción

*   **Suministrar MySQL:** Asegurar una instancia de MySQL accesible para producción.
*   **Crear Usuario Dedicado:**
    *   Crear un usuario específico para la aplicación TPV_Bar (p. ej., `tpv_user`) con una contraseña segura. No usar `root`.
    *   Ejemplo SQL: `CREATE USER 'tpv_user'@'host_servidor_app' IDENTIFIED BY 'contraseña_segura';`
*   **Crear Esquema:**
    *   Crear la base de datos (p. ej., `tpv_bar_prod`).
    *   Ejemplo SQL: `CREATE DATABASE tpv_bar_prod;`
*   **Otorgar Privilegios:**
    *   Conceder los permisos necesarios al `tpv_user` sobre el esquema `tpv_bar_prod` (SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, etc.).
    *   Ejemplo SQL: `GRANT ALL PRIVILEGES ON tpv_bar_prod.* TO 'tpv_user'@'host_servidor_app'; FLUSH PRIVILEGES;`
*   **Gestión del Esquema (Tablas):**
    *   Revisar la propiedad `hibernate.hbm2ddl.auto` en `hibernate.cfg.xml`.
    *   Para la creación inicial, se puede establecer temporalmente a `create` o `update`. Para operación normal, `validate` o dejarla sin definir (gestión manual).

### 2. Configurar la Aplicación para el Entorno de Producción

*   **Modificar `src/es/tpv_bar/persistencia/hibernate.cfg.xml`:**
    *   `hibernate.connection.url`: Actualizar a la URL de la base de datos de producción (ej: `jdbc:mysql://servidor_bd_prod:3306/tpv_bar_prod`).
    *   `hibernate.connection.username`: Cambiar al usuario de producción (ej: `tpv_user`).
    *   `hibernate.connection.password`: Cambiar a la contraseña del usuario de producción.
    *   `hibernate.show_sql`: Recomendado establecer a `false` para producción.
    *   `hibernate.hbm2ddl.auto`: Ajustar según la estrategia de gestión del esquema (ej: `validate`).
*   **Consideraciones de Seguridad:** Evitar guardar credenciales directamente en el control de versiones a largo plazo. Explorar archivos de configuración externos o variables de entorno.

### 3. Construir (Compilar y Empaquetar) la Aplicación

*   **Navegar a la raíz del proyecto.**
*   **Ejecutar Ant:**
    ```bash
    ant clean dist
    ```
*   **Resultado:** Se generará el directorio `dist/` conteniendo:
    *   `TPV_Bar.jar`: El JAR ejecutable principal.
    *   `lib/`: Subdirectorio con todas las dependencias (JARs).

### 4. Desplegar en el Servidor de Producción

*   **Elegir Directorio:** Seleccionar una ubicación en el servidor de producción (ej: `/opt/tpv_bar/app/`).
*   **Transferir Archivos:** Copiar el contenido completo del directorio `dist/` (generado en el paso anterior) al directorio elegido en el servidor de producción.
    *   Usar herramientas como `scp` o `rsync`. Ejemplo con `rsync`:
        ```bash
        rsync -avz dist/ usuario@servidor_produccion:/opt/tpv_bar/app/
        ```
*   **Verificar:** Confirmar que `TPV_Bar.jar` y la carpeta `lib/` están correctamente desplegados.

### 5. Ejecutar la Aplicación en Producción

*   **Navegar al Directorio de Despliegue:**
    ```bash
    cd /opt/tpv_bar/app/
    ```
*   **Ejecutar el JAR:**
    ```bash
    java -jar TPV_Bar.jar
    ```
*   **Entorno Gráfico:** Recordar que la máquina donde se ejecute debe tener un entorno gráfico para que la interfaz Swing sea visible.
*   **Revisar Logs/Consola:** Observar si hay errores al inicio.

### 6. Consideraciones de Monitorización y Mantenimiento

*   **Logging Avanzado:**
    *   Configurar Log4j (ya presente como dependencia) para registrar en archivos, con niveles y rotación. Crear un `log4j.properties` o `log4j.xml`.
*   **Monitorización:**
    *   Salud de la aplicación (proceso en ejecución, logs de errores).
    *   Uso de recursos del sistema (CPU, memoria).
    *   Rendimiento y salud de la base de datos MySQL.
*   **Mantenimiento:**
    *   **Actualizaciones:** Definir un proceso para desplegar nuevas versiones.
    *   **Copias de Seguridad:** Implementar backups regulares y automatizados de la base de datos. Probar restauraciones.
    *   **Actualización de Dependencias:** Revisar periódicamente por seguridad.
    *   **Seguridad del Entorno:** Mantener actualizados SO, JRE y MySQL.
*   **Documentación:** Mantener actualizada la documentación del despliegue y operación.

---
Este README proporciona una guía general. Es crucial adaptar los detalles específicos (como nombres de host, usuarios, rutas) a su entorno particular.
```
