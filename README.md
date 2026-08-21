# proyecto_grupo

## Descripción del proyecto

Repositorio desarrollado para el **Laboratorio 1 — Colaboración con Git y GitHub**, de la asignatura Principios de Desarrollo de Software (Pontificia Universidad Javeriana). El objetivo del proyecto es poner en práctica el flujo de trabajo colaborativo estándar de Git y GitHub: autenticación, clonación, trabajo en ramas independientes, apertura y revisión de pull requests, y resolución de un conflicto de merge provocado intencionalmente. Adicionalmente, se realizó un experimento comparativo entre las operaciones `merge` y `rebase` para evidenciar sus diferencias sobre el historial de commits.

## Integrantes del grupo

- Miguel Escobar Díaz
- Alejandro Méndez Ducuara
- Juan Andrés Sanabria Prieto

## Comandos utilizados

| Comando | Propósito |
|---|---|
| `git --version` | Verificar que Git quedó correctamente instalado. |
| `git config --global user.name "Tu Nombre"` | Configurar el nombre de autor que aparecerá en los commits. |
| `git config --global user.email "correo@javeriana.edu.co"` | Configurar el correo de autor, asociado a la cuenta de GitHub. |
| `gh auth login` | Autenticar el computador con GitHub a través del navegador. |
| `gh auth status` | Comprobar que la autenticación con GitHub CLI quedó activa. |
| `git clone URL` | Descargar una copia local completa del repositorio remoto. |
| `cd proyecto_grupo` | Ubicarse dentro del directorio del repositorio clonado. |
| `git branch --show-current` | Confirmar en qué rama se encuentra el repositorio local. |
| `mkdir src docs tests` | Crear la estructura de carpetas inicial del proyecto. |
| `git status` | Revisar qué archivos cambiaron y en qué estado se encuentran. |
| `git add .` | Preparar (stage) todos los cambios para el siguiente commit. |
| `git commit -m "..."` | Guardar los cambios preparados en el historial local. |
| `git push origin main` | Subir los commits locales de `main` al repositorio remoto. |
| `git pull origin main` | Traer y aplicar a la copia local los cambios subidos por otros integrantes. |
| `git checkout -b feature-<nombre>` | Crear una rama nueva por integrante y moverse a ella. |
| `git push -u origin feature-<nombre>` | Publicar por primera vez una rama nueva y vincularla con su remoto. |
| `git checkout main` | Cambiar a la rama `main`. |
| `git merge main` | Integrar los cambios de `main` en la rama actual (aquí se provocó el conflicto). |
| `git add index.html` | Marcar como resuelto el archivo en conflicto tras editarlo manualmente. |
| `git push origin feature-<nombre>` | Subir la rama con el conflicto ya resuelto. |
| `git log --oneline --graph --all --decorate` | Visualizar el historial de commits en forma de árbol, con todas las ramas. |
| `git rebase main` | Reubicar los commits de una rama sobre la punta actual de `main`, generando un historial lineal (experimento de la sección 8). |
| `git restore <archivo>` | Descartar cambios locales no confirmados de un archivo. |
| `git merge --abort` | Cancelar un merge que quedó a medias y volver al estado previo. |

## Enlace al repositorio

https://github.com/maed2006m/proyecto_grupo
