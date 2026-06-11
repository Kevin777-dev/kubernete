FROM python:3.10

# Ne pas lancer les app en root dans docker
RUN useradd flask

WORKDIR /home/flask

# Ajouter tout le contexte sauf le contenu de .dockerignore
ADD . .

# Installer les dépendances Python (pas besoin de venv dans Docker)
RUN pip install -r requirements.txt

RUN chmod a+x app.py test.py && \
    chown -R flask:flask ./

# Déclarer la config de l'app
ENV FLASK_APP=app.py

EXPOSE 5000

# Changer d'user pour lancer l'app
USER flask

CMD ["python", "app.py"]