///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определяет наименование с сокращением региона по его коду.
//
// Параметры:
//    КодСубъектаРФ - Число, Строка - код региона. Например, 50.
//
// Возвращаемое значение:
//    Строка       - наименование и сокращение региона. Например, "Московская обл".
//    Неопределено - если регион не найден.
//
Функция НаименованиеРегионаПоКоду(КодСубъектаРФ) Экспорт
	
	Запрос = Новый Запрос("
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	Наименование + "" "" + Сокращение КАК Наименование
		|ИЗ
		|	РегистрСведений.АдресныеОбъекты
		|ГДЕ
		|	Уровень = 1
		|	И КодСубъектаРФ = &КодСубъектаРФ
		|");
		
	ТипЧисло = Новый ОписаниеТипов("Число");
	ЧисловойКодСубъекта = ТипЧисло.ПривестиЗначение(КодСубъектаРФ);
		
	Запрос.УстановитьПараметр("КодСубъектаРФ", ЧисловойКодСубъекта );
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		Возврат Выборка.Наименование;
	КонецЕсли;
	
	// Если не нашли, то подсмотрим еще и в классификаторе - макете.
	Классификатор = РегистрыСведений.АдресныеОбъекты.КлассификаторСубъектовРФ();
	Вариант = Классификатор.Найти(КодСубъектаРФ, "КодСубъектаРФ");
	Если Вариант = Неопределено Тогда
		// Не нашли
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Вариант.Наименование + " " + Вариант.Сокращение;
КонецФункции

// Возвращает код региона по наименованию.
//
// Параметры:
//    Название - Строка - наименование или полное наименование (с сокращением) региона.
//                        Например, "Московская" или Московская обл".
//
// Возвращаемое значение:
//    Число        - код региона, например, 50.
//    Неопределено - если данные не найдены.
//
Функция КодРегионаПоНаименованию(Название) Экспорт
	
	Запрос = Новый Запрос("
		|ВЫБРАТЬ 
		|	Варианты.КодСубъектаРФ
		|ИЗ (
		|	ВЫБРАТЬ ПЕРВЫЕ 1
		|		1             КАК Порядок,
		|		КодСубъектаРФ КАК КодСубъектаРФ
		|	ИЗ
		|		РегистрСведений.АдресныеОбъекты
		|	ГДЕ
		|		Уровень = 1 
		|		И Наименование = &Название
		|
		|	ОБЪЕДИНИТЬ ВСЕ
		|
		|	ВЫБРАТЬ ПЕРВЫЕ 1
		|		2             КАК Порядок,
		|		КодСубъектаРФ КАК КодСубъектаРФ
		|	ИЗ
		|		РегистрСведений.АдресныеОбъекты
		|	ГДЕ
		|		Уровень = 1 
		|		И Наименование = &Наименование
		|		И Сокращение   = &Сокращение
		|) КАК Варианты
		|
		|УПОРЯДОЧИТЬ ПО
		|	Варианты.Порядок
		|");
		
	ЧастиСлова = АдресныйКлассификаторСлужебный.НаименованиеИСокращение(Название);
	Запрос.УстановитьПараметр("Наименование", ЧастиСлова.Наименование);
	Запрос.УстановитьПараметр("Сокращение",   ЧастиСлова.Сокращение);
	Запрос.УстановитьПараметр("Название",     Название);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		Возврат Выборка.КодСубъектаРФ;
	КонецЕсли;

	// Если не нашли, то подсмотрим еще и в классификаторе - макете.
	Классификатор = РегистрыСведений.АдресныеОбъекты.КлассификаторСубъектовРФ();
	
	Фильтр = Новый Структура("Наименование", Название);
	Варианты = Классификатор.НайтиСтроки(Фильтр);
	Если Варианты.Количество() = 0 Тогда
		Фильтр.Вставить("Наименование", ЧастиСлова.Наименование);
		Фильтр.Вставить("Сокращение",   ЧастиСлова.Сокращение);
		Варианты = Классификатор.НайтиСтроки(Фильтр);
	КонецЕсли;
	
	Если Варианты.Количество() > 0 Тогда
		Возврат Варианты[0].КодСубъектаРФ;
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции

// Возвращает информацию о субъектах РФ определенных в федеральной информационной адресной системе.
//
// Возвращаемое значение:
//     ТаблицаЗначений - сведения о субъектах(регионах) РФ:
//       * КодСубъектаРФ  - Число                   - код субъекта, например 77 для Москвы.
//       * Наименование   - Строка                  - наименование субъекта. Например "Московская".
//       * Сокращение     - Строка                  - сокращение субъекта. Например "обл".
//       * ПочтовыйИндекс - Число                   - индекс региона. Если 0 - то индекс не определен.
//       * Идентификатор  - УникальныйИдентификатор - уникальный идентификационный код адресного объекта.
//
Функция СубъектыРФ() Экспорт
	
	Возврат РегистрыСведений.АдресныеОбъекты.КлассификаторСубъектовРФ();
	
КонецФункции

// Возвращает количество загруженных в адресный классификатор субъектов РФ.
// Из-за проверки доступности веб-сервиса выполнение функции может занимать 7 секунд.
// Поэтому для исключения зависаний пользовательского интерфейса, например при открытии формы,
// следует вызвать в фоновом задании.
// Т.к. при использовании веб-сервиса фирмы "1С" предоставляющего через Интернет сведения об
// адресах РФ в формате ФИАС, всегда доступны адресные сведения по всем регионам РФ,
// то возвращает общее количество субъектов РФ.
//
// Возвращаемое значение:
//    Число - количество субъектов РФ, содержащих загруженные адресные сведения в адресном классификаторе.
//
Функция КоличествоЗагруженныхРегионов() Экспорт
	
	Если АдресныйКлассификаторПовтИсп.ИсточникДанныхАдресногоКлассификатораВебСервис() Тогда
		Возврат СубъектыРФ().Количество();
	КонецЕсли;
	
	Запрос = Новый Запрос("
		|ВЫБРАТЬ
		|	КОЛИЧЕСТВО(Регионы.КодСубъектаРФ) КАК КоличествоЗагруженных
		|ИЗ
		|	РегистрСведений.АдресныеОбъекты КАК Регионы
		|ГДЕ
		|	Регионы.Уровень = 1
		|	И 1 В (
		|		ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 2 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 3 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 4 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 5 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 6 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 7 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 90 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|		ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ПЕРВЫЕ 1 1 ИЗ РегистрСведений.АдресныеОбъекты
		|		ГДЕ Уровень = 91 И КодСубъектаРФ = Регионы.КодСубъектаРФ
		|	)
		|");
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.КоличествоЗагруженных;
	КонецЕсли;
	
	Возврат 0;
КонецФункции

// Определяет наличие адресных сведений в адресном классификаторе.
// Из-за проверки доступности веб-сервиса выполнение функции может занимать 7 секунд.
// Поэтому для исключения зависаний пользовательского интерфейса, например при открытии формы,
// функцию следует вызвать в фоновом задании.
// При использовании веб-сервиса фирмы "1С" предоставляющего через Интернет сведения об
// адресах РФ в формате ФИАС, всегда возвращает Истина, если подключена интернет-поддержка пользователей.
//
// Возвращаемое значение:
//     Булево - Истина, если адресный классификатор содержит сведения хотя бы по одному региону
//              или подключен и доступен веб-сервис.
//              Ложь, если адресные сведения отсутствуют, а веб-сервис недоступен.
//
Функция АдресныйКлассификаторЗагружен() Экспорт
	
	Запрос = Новый Запрос("
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	КодСубъектаРФ
		|ИЗ
		|	РегистрСведений.АдресныеОбъекты
		|ГДЕ
		|	Уровень > 1
		|");
	
	Если Не Запрос.Выполнить().Пустой() Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат АдресныйКлассификаторПовтИсп.ИсточникДанныхАдресногоКлассификатораВебСервис();
	
КонецФункции

// Проверяет адреса на соответствие адресному классификатору
// и возвращает подходящие варианты, содержащие сведения об адресе.
// При проверке адреса через веб-сервиса выполнение функции может занимать 20 секунд.
// Поэтому для исключения зависаний пользовательского интерфейса, например при открытии формы,
// функцию следует вызвать в фоновом задании.
//
// Параметры:
//     Адреса - Массив - проверяемые адреса. Содержит структуры с полями:
//         * Адрес                          - проверяемый адрес во внутреннем формате JSON или в XML,
//                                            соответствующем XDTO-пакету Адрес (http://www.v8.1c.ru/ssl/contactinfo),
//                                            или его XML-сериализация, соответствующая структуре XDTO-пакета.
//         * ФорматАдреса - Строка - устарело. Формат адреса. Варианты:
//                                    * ФИАС адрес проверяется по всем уровням адреса;
//                                    * КЛАДР - у адреса не проверяются на соответствие номера домов, округа,
//                                      внутригородские районы, доп. территории и элементы доп. территорий.
//
// Возвращаемое значение:
//     Массив - результаты анализа. Каждый элемент массива содержит структуры с полями:
//       * Ошибки   - Массив     - описание ошибок поиска в классификаторе. Состоит из массива структур с полями:
//           ** Ключ      - Строка - служебный идентификатор места ошибки (путь XPath в объекте XDTO).
//           ** Текст     - Строка - текст ошибки.
//           ** Подсказка - Строка - текст возможного исправления ошибки.
//       * Варианты - Массив     - устарело. Содержит описание найденных вариантов в виде массива структур с полями:
//           ** Идентификатор    - УникальныйИдентификатор - уникальный идентификационный код адресного объекта ФИАС.
//           ** Индекс           - Число - почтовый индекс адресного объекта.
//           ** КодКЛАДР         - Число - код КЛАДР ближайшего объекта.
//           ** OKATO            - Число - код общероссийского классификатора объектов административно-территориального деления.
//           ** ОКТМО            - Число - код общероссийского классификатора территорий муниципальных образований.
//           ** КодИФНСФЛ        - Строка - код инспекции ФНС обслуживающей физических лиц.
//           ** КодИФНСЮЛ        - Строка - код инспекции ФНС обслуживающей юридические лица.
//           ** КодУчасткаИФНСФЛ - Строка - код территориального участка инспекции ФНС обслуживающей физических лиц.
//           ** КодУчасткаИФНСЮЛ - Строка - код территориального участка инспекции ФНС обслуживающей юридические лица.
//
// Пример:
//     СтруктураПроверки = Новый Структура("Адрес, ФорматАдреса", Адрес, "ФИАС");
//     РезультатыПроверки = АдресныйКлассификатор.ПроверитьАдреса(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(СтруктураПроверки));
//
//     Если РезультатыПроверки.Количество() > 0 И РезультатыПроверки.Варианты.Количество() > 0 Тогда
//      	КодКЛАДР = РезультатыПроверки.Варианты[0].КодКЛАДР;
//     КонецЕсли;
//
Функция ПроверитьАдреса(Адреса) Экспорт
	
	АдресаСтруктурой = Новый Массив;
	Для каждого ПроверяемыйАдрес Из Адреса Цикл
		Если ТипЗнч(ПроверяемыйАдрес) = Тип("Структура") Тогда
			Если ПроверяемыйАдрес.Свойство("Адрес") Тогда
				Адрес = Новый Структура("Адрес", АдресныйКлассификаторСлужебный.КонтактнаяИнформацияВСтруктуруJSON(ПроверяемыйАдрес.Адрес, ""))
			Иначе
				Адрес = "";
			КонецЕсли;
		Иначе
			Адрес = Новый Структура("Адрес", АдресныйКлассификаторСлужебный.КонтактнаяИнформацияВСтруктуруJSON(ПроверяемыйАдрес, ""))
		КонецЕсли;
	
		АдресаСтруктурой.Добавить(Адрес);
	КонецЦикла;
	
	Результат = АдресныйКлассификаторСлужебный.РезультатПроверкиАдресовПоКлассификатору(АдресаСтруктурой);
	Возврат Результат.Данные;
	
КонецФункции

// Возвращает полное наименование адресного объекта по его сокращению.
// Если уровень не указан, то возвращает первое найденное совпадение.
//
// Параметры:
//  АдресноеСокращение - Строка - сокращение адресного объекта. Например, "г".
//  Уровень            - Число - код уровня адресного объекта. Например, для уровня города 4.
//
// Возвращаемое значение:
//  Строка       - полное наименование адресного объекта. Например, "город".
//  Неопределено - если сокращение не найдено.
//
Функция ПолноеНаименованиеАдресногоСокращения(АдресноеСокращение, Уровень = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1 
		|	УровниСокращенийАдресныхСведений.Значение КАК Наименование
		|ИЗ
		|	РегистрСведений.УровниСокращенийАдресныхСведений КАК УровниСокращенийАдресныхСведений
		|ГДЕ
		|	УровниСокращенийАдресныхСведений.Сокращение = &Сокращение";
	
	Если ЗначениеЗаполнено(Уровень) Тогда 
		Запрос.Текст = Запрос.Текст + " И УровниСокращенийАдресныхСведений.Уровень = &Уровень";
		Запрос.УстановитьПараметр("Уровень", Уровень);
	КонецЕсли;
	Запрос.УстановитьПараметр("Сокращение", АдресноеСокращение);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		Возврат РезультатЗапроса.Наименование;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Возвращает коды адрес (ОКТМО, ОКАТО, налоговых инспекций ФНС и др.) и
// уникальные идентификационные коды адресного объекта и дома.
// Кода не будут заполнены, если адрес не соответствует ФИАС или содержит адресные поля без идентификаторов.
// При получении кодов через веб-сервиса выполнение функции может занимать 20 секунд.
// Поэтому для исключения зависаний пользовательского интерфейса, например при открытии формы,
// функцию следует вызвать в фоновом задании.
//
// Параметры:
//  Адрес    - Строка - адрес во внутреннем формате JSON или XML, соответствующий структуре XDTO-пакета Адрес.
//  Источник - Строка - источник получения кодов адреса:
//             "Сервис1С" - коды будут получены через веб-сервис "1С" предоставляющий сведения об адресах РФ в формате ФИАС;
//             "ЗагруженныеДанные" - сначала будет попытка определить коды по загруженным данным адресного классификатора,
//                                   а затем, если коды не были определены, то они будут получены через веб-сервис "1С".
//             Если параметр не указан, то определение кодов будет аналогично параметру ЗагруженныеДанные.
// Возвращаемое значение:
//  Структура - коды адреса. Если адрес не найден, то поля структуры содержат пустые значения.
//      * Идентификатор - Строка - уникальный идентификационный код адресного объекта ФИАС.
//      * ИдентификаторДома - Строка - уникальный идентификационный код дома(здания) адресного объекта ФИАС.
//      * КодКЛАДР - Строка - код классификатор адресов России (КЛАДР).
//      * КодИФНСФЛ - Строка - код инспекции ФНС, обслуживающей физических лиц.
//      * КодИФНСЮЛ - Строка - код инспекции ФНС, обслуживающей юридические лица.
//      * КодУчасткаИФНСФЛ - Строка - код территориального участка инспекции ФНС, обслуживающей физических лиц.
//      * КодУчасткаИФНСЮЛ - Строка - код территориального участка инспекции ФНС, обслуживающей юридические лица.
//      * OKATO - Строка - код общероссийского классификатора объектов административно-территориального деления.
//      * ОКТМО - Строка - код общероссийского классификатора территорий муниципальных образований.
//
Функция КодыАдреса(Адрес, Источник = Неопределено) Экспорт
	
	Коды = АдресныйКлассификаторСлужебный.КодыАдреса(Адрес, Источник);
	Если ТипЗнч(Коды) = Тип("Структура") И Коды.Свойство("КодыАдреса") Тогда
		Коды = Коды.КодыАдреса;
	КонецЕсли;
	Возврат Коды;
	
КонецФункции

// Возвращает соответствие полных наименований адресных объектов и их сокращения.
//
// Параметры:
//  НаименованияАдресныхОбъектов - Массив - полные наименования адресных объектов. Если передан пустой массив,
//                                          то будут возвращен полный список наименований и сокращений.
//
// Возвращаемое значение:
//  Соответствие - соответствие найденных полных наименований адресных объектов их сокращениям.
//
Функция СокращенияАдресныхОбъектов(НаименованияАдресныхОбъектов) Экспорт
	Возврат АдресныйКлассификаторСлужебный.СокращенияАдресныхОбъектов(НаименованияАдресныхОбъектов);
КонецФункции

#Область УстаревшиеПроцедурыИФункции

// Возвращает идентификационный код дома и адресного объекта с помощью веб-сервиса фирмы 1С предоставляющего
// сведения об адресах РФ в формате ФИАС. Для получения идентификаторов требуется подключение
// к Интернет-поддержке пользователей и наличие постоянного соединения с интернетом,
// т.к. адресные сведения, загруженные в программу, не используются.
//
// Параметры:
//   Адрес                               - Строка - XML соответствующий структуре XDTO-пакета Адрес, содержащий адрес,
//                                                  для которого требуется определить идентификационные коды.
// Возвращаемое значение:
//   Структура - со свойствами:
//       * ИдентификаторАдресногоОбъекта - УникальныйИдентификатор - идентификационный код адресного объекта (улицы,
//                                                                   нас. пункта).
//       * ИдентификаторДома             - УникальныйИдентификатор - идентификационный код дома адресного объекта.
//       * Отказ                         - Булево - если Истина, то при работе с веб-сервисом возникла ошибка.
//       * ПодробноеПредставлениеОшибки  - Строка - полное описание ошибки, если при работе с веб-сервисом возникла
//                                                  ошибка, иначе Неопределено.
//       * КраткоеПредставлениеОшибки    - Строка - краткое описание ошибки, если при работе с веб-сервисом возникла
//                                                  ошибка, иначе Неопределено.
//
Функция ИдентификаторыАдреса(Адрес) Экспорт
	Возврат АдресныйКлассификаторСлужебный.ОпределитьИдентификаторыАдреса(Адрес);
КонецФункции

#КонецОбласти

#КонецОбласти