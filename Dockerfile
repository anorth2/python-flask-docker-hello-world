FROM python:3.7
COPY . /app
WORKDIR /app
RUN pip install -r requirements.project.txt
ENTRYPOINT ["python"]
EXPOSE 80
CMD ["app.py"]
