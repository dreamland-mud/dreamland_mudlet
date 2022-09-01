# Dreamland Mudlet Package

Dreamland мапер, статы, и чат! [Посмотреть как ето всё работает](https://streamable.com/jqbua).

![Dreamland UI](https://forums.mudlet.org/download/file.php?id=1654&mode=view)

## Установка
Создай новый профиль в Mudlet для DreamLand и укажи в адрессе dreamland.rocks порт 9000
При подсоединении Mudlet предложит тебе скачать пакет Dreamland, скажи да
Зайди в триггеры и отключи стандартные триггеры для '''generic_mapper''' либо удали их
В командной строке сделай map update чтоб обновить версию Generic Mapper Script-а до самой последней


## Статы
Как и в веб-клиенте, с плюсом что автоматически показывает бар для противника в бою

## Мапер
Играй картографа! Нарисуй мир, и мапер автоматически будет показывать где ты в нём. Хочешь пойти куда-то? Нажми на комнату в карте, и мапер тебя поведёт (speedwalk).

Для картографии (основан на [generic mapper script](https://forums.mudlet.org/viewtopic.php?f=13&t=6105)):
```
    Important Commands (Aliases) for Proper Mapping

        Fundamental Aliases
        start mapping <optional area name> - use this command to start adding new content
            to the map, area name is required if there are no rooms in the map
        stop mapping - use this command to stop mapping
        save map - saves the map to a file (map.dat, located in the profile folder), this
            is generally only needed to share the map with someone else, or to act as a
            backup in case something happens to the map that Mudlet maintains for your
            profile
        load map <optional 'local'> - loads the map from the location specified in the
            download_path, or from the local copy
        export area <area name> - exports a file to the profile folder with data for the
            named area
        import area <area name> - imports area data from a file created with export area,
            must be located in profile folder
        mstop - остановить speedwalk.


        Mapping Aliases
        map mode <simple, normal, or complex> - sets the mapping mode, determining what
            exits are set automatically as you move around
        set area <area name> - move the current room into the named area, area will be
            created if it does not currently exist
        shift <direction> - use this command to move the room you are currently in around
            on the map
        merge rooms - use this command to combine the room you are in with any other rooms
            in the same location and with the same name
        clear moves - use this command to clear the move queue after you attempt a move
            that doesn't succeed, but for which there is no trigger indicating this with
            the onMoveFail event
        add door <direction> <optional none, open, closed, locked> <optional yes, no> -
            adds a door in the given direction, defaulting to closed (use none to remove
            a door), and defaulting 'no' for one-way status
        add portal <entry command> - adds a portal that uses the given command for entry
            to force this command to create a new room, rather than linking to an existing
            one, put -f before the entry command, like this: add portal -f enter portal
        set exit <direction> <roomID> - sets the given direction to connect, one way,
            to the room with the specified roomID, used for very complex areas
            to set the destination room for a portal, put -p before the portal entry command
            like this: set exit -p enter portal 1124

        Normal User Aliases
        find me - use this command to search the entire map to try to locate you based on
            room name and exits, typically not necessary, as this will be done anyway if
            a person moves and their location is unknown
        find path <room name> OR <room name> ; <area name> - used to find a walking path
            to a room with the given name, in the given area if specified
        set character <name> - sets the current character name (stored as map.character)
        set recall - sets the current room as the recall room for the current character
```

## Чат
Не пропускай что было сказано в спаме! Чат запоминает в отдельное окошко и даже разбивает на разные табы.

## Импорт вручную
Oткрой Package Manager с меню и импортируй весь зип.

## Для разработчиков
Инсталлируйте .xml в Module Manager - при сохранения профиля, .xml автоматически будет обновлён.

