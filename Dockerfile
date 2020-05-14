FROM osrm/osrm-backend

RUN apt-get update && apt-get install -y wget

COPY profiles /profiles/

COPY . /app

RUN chmod +777 /app/launch.sh

EXPOSE 5000

CMD ["/app/launch.sh"]
