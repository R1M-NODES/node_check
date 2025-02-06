#!/bin/bash

# Назва контейнера
CONTAINER_NAME="privasea-node"

# Шлях до цього скрипту
SCRIPT_PATH="$(realpath "$0")"

# Перевірка статусу контейнера
STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)

if [ "$STATUS" != "running" ]; then
  echo "Контейнер $CONTAINER_NAME не працює (статус: $STATUS). Спробую перезапустити..."
  docker start $CONTAINER_NAME
  if [ $? -eq 0 ]; then
    echo "Контейнер $CONTAINER_NAME успішно перезапущено."
  else
    echo "Не вдалося перезапустити контейнер $CONTAINER_NAME."
  fi
else
  echo "Контейнер $CONTAINER_NAME працює."
fi

# Додавання скрипту в cron, якщо ще не додано
CRON_JOB="*/5 * * * * $SCRIPT_PATH"
if ! (crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"); then
  echo "Додаю скрипт до cron для запуску кожні 5 хвилин..."
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  if [ $? -eq 0 ]; then
    echo "Скрипт успішно додано до cron."
  else
    echo "Не вдалося додати скрипт до cron."
  fi
else
  echo "Скрипт вже додано до cron."
fi
