import Foundation

let stations: [Station] = [
    Station(
		id: Constants.PlanetName.alphaOrbital,
        name: "Альфа-Орбиталь",
        type: "Орбитальная",
        description: "Крупный торговый узел на низкой орбите планеты Альфа.",
        imageName: "1",
		tradeItems: [
			TradeItem(id: "alpha-fuel", name: "Орбитальное топливо", price: 120, description: "Стандартное топливо для дальних перелётов."),
			TradeItem(id: "alpha-alloy", name: "Титановый сплав", price: 340, description: "Надёжный конструкционный материал."),
			TradeItem(id: "alpha-nav", name: "Навигационный модуль", price: 520, description: "Модуль для точных межсекторных прыжков.")
		]
    ),
    Station(
		id: "beta-port",
        name: "Бета-Порт",
        type: "Планетарная",
        description: "Поверхностный космопорт, известный дешёвым топливом.",
        imageName: "2",
		tradeItems: [
			TradeItem(id: "beta-water", name: "Очищенная вода", price: 60, description: "Базовый ресурс для дальних маршрутов."),
			TradeItem(id: "beta-food", name: "Пищевые контейнеры", price: 95, description: "Долговременные пайки для экипажа."),
			TradeItem(id: "beta-bio", name: "Биоматериалы", price: 210, description: "Органические компоненты для лабораторий и медблоков.")
		]
    ),
    Station(
		id: "gamma-transit",
        name: "Гамма-Транзит",
        type: "Перевалочная",
        description: "Транзитная станция на границе сектора, высокий трафик.",
        imageName: "3",
		tradeItems: [
			TradeItem(id: "gamma-drones", name: "Сервисные дроны", price: 410, description: "Компактные дроны для ремонта и логистики."),
			TradeItem(id: "gamma-parts", name: "Запчасти класса C", price: 190, description: "Универсальные компоненты для корабельных систем."),
			TradeItem(id: "gamma-crates", name: "Грузовые контейнеры", price: 150, description: "Контейнеры для безопасной перевозки товаров.")
		]
    ),
    Station(
		id: "delta-science",
        name: "Дельта-Научная",
        type: "Исследовательская",
        description: "Лабораторный комплекс, редкие товары и модификации.",
        imageName: "4",
		tradeItems: [
			TradeItem(id: "delta-meds", name: "Медицинские наниты", price: 630, description: "Продвинутые системы восстановления и лечения."),
			TradeItem(id: "delta-crystals", name: "Квантовые кристаллы", price: 880, description: "Редкий компонент для высокоточных систем."),
			TradeItem(id: "delta-scans", name: "Сканирующая матрица", price: 540, description: "Аппаратный модуль для научных сенсоров.")
		]
    ),
    Station(
		id: "epsilon-outpost",
        name: "Эпсилон-Отдалённая",
        type: "Форпост",
        description: "Малый форпост на окраине системы, ограниченные услуги.",
        imageName: "5",
		tradeItems: [
			TradeItem(id: "epsilon-ore", name: "Редкая руда", price: 470, description: "Сырьё с окраинных астероидных полей."),
			TradeItem(id: "epsilon-relic", name: "Артефакты фронтира", price: 760, description: "Находки с заброшенных колоний."),
			TradeItem(id: "epsilon-batteries", name: "Энергоячейки", price: 260, description: "Надёжные батареи для автономных систем.")
		]
    )
]

