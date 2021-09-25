FROM python:3.8
RUN apt-get update
RUN mkdir /usr/src/app
RUN useradd -U django
RUN mkdir /home/django && chown django:django /home/django
USER django
ENV MICRO_SERVICE=/usr/src/app/django
COPY --chown=django:django . $MICRO_SERVICE
WORKDIR $MICRO_SERVICE
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH=$PATH:/home/django/.local/bin
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
WORKDIR /usr/src/app/django/my_cv
