#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	 ПараметрыФормы = Новый Структура("", );
	 ОткрытьФорму("РегистрСведений.НапоминанияПользователя.Форма.фмНапоминанияПользователям", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно);
КонецПроцедуры

#КонецОбласти
