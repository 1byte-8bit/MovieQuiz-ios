## **MovieQuiz**

MovieQuiz - это приложение с квизами о фильмах из топ-250 рейтинга и самых популярных фильмах по версии IMDb.

<p align="left">
  <img src="https://github.com/1byte-8bit/1byte-8bit/blob/main/main_movie_quiz.gif?raw=true">
</p>

## **Ссылки**

[Макет Figma](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)

[API IMDb](https://imdb-api.com/api#Top250Movies-header)

[Шрифты](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)

## **Описание приложения**

- Одностраничное приложение с квизами о фильмах из топ-250 рейтинга и самых популярных фильмов IMDb. Пользователь приложения последовательно отвечает на вопросы о рейтинге фильма. По итогам каждого раунда игры показывается статистика о количестве правильных ответов и лучших результатах пользователя. Цель игры — правильно ответить на все 10 вопросов раунда.

## **Функциональные требования**

- При запуске приложения показывается сплеш-скрин;
- После запуска приложения показывается экран вопроса с текстом вопроса, картинкой и двумя вариантами ответа, “Да” и “Нет”, только один из них правильный;
- Вопрос квиза составляется относительно IMDb рейтинга фильма по 10-балльной шкале, например: "Рейтинг этого фильма больше 6?";
- Можно нажать на один из вариантов ответа на вопрос и получить отклик о том, правильный он или нет, при этом рамка фотографии поменяет цвет на соответствующий;
- После выбора ответа на вопрос через 1 секунду автоматически появляется следующий вопрос;
- После завершения раунда из 10 вопросов появляется алерт со статистикой пользователя и возможностью сыграть ещё раз;
- Статистика содержит: результат текущего раунда (количество правильных ответов из 10 вопросов), количество сыгранных квизов, рекорд (лучший результат раунда за сессию, дата и время этого раунда), статистику сыгранных квизов в процентном соотношении (среднюю точность);
- Пользователь может запустить новый раунд, нажав в алерте на кнопку "Сыграть еще раз";
- При невозможности загрузить данные пользователь видит алерт с сообщением о том, что что-то пошло не так, а также кнопкой, по нажатию на которую можно повторить сетевой запрос.

## **Технические требования**

- Приложение должно поддерживать устройства iPhone с iOS 13, предусмотрен только портретный режим;
- Элементы интерфейса адаптируются под разрешения экранов iPhone, начиная с X — вёрстка под SE и iPad не предусмотрена;
- Экраны соответствует макету — использованы верные шрифты нужных размеров, все надписи находятся на нужном месте, расположение всех элементов, размеры кнопок и отступы — точно такие же, как в макете.
