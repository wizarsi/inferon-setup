#!/bin/bash

# Обработка ошибок
set -e

# Установка Ollama
echo "Устанавливаем Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Удаление старой версии Infera
echo "Удаляем старую версию Infera, если существует..."
rm -rf ~/infera

# Скачивание и установка новой версии Infera
echo "Скачиваем новую версию Infera..."
curl -O https://www.infera.org/scripts/infera-linux-intel.sh
chmod +x ./infera-linux-intel.sh
echo "Устанавливаем Infera..."
./infera-linux-intel.sh

# Проверка и обновление окружения
if ! grep -q 'alias init-infera' ~/.bashrc; then
    echo "Обновляем .bashrc для поддержки Infera..."
    echo "alias init-infera='source ~/infera/init.sh'" >> ~/.bashrc
    source ~/.bashrc
else
    echo ".bashrc уже содержит alias для Infera."
fi

# Создание директории Docker и подготовка файлов
echo "Создаем директорию для Docker..."
mkdir -p ~/infera-docker
cd ~/infera-docker

echo "Копируем Infera в директорию Docker..."
cp ~/infera ./

# Создание Dockerfile
echo "Создаем Dockerfile..."
cat <<EOF > Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl file
COPY infera /app/infera
RUN chmod +x /app/infera
WORKDIR /app
CMD ["./infera"]
EOF

# Сборка Docker-образа
echo "Собираем Docker-образ..."
sudo docker build -t infera-app .

# Запуск Docker-контейнера
echo "Запускаем Docker-контейнер..."
sudo docker run -d --rm --network="host" infera-app

echo "Установка завершена!"
