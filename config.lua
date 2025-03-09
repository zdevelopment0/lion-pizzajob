Config = {}

Config.JobName = "pizza"
Config.BlipName = "Pizza Dağıtım Merkezi"
Config.UseTarget = false

Config.NPCSettings = {
    model = "ig_claypain",
    coords = vector4(538.37, 101.24, 96.54, 163.31),
    animation = {
        enabled = true,
        dict = "amb@world_human_clipboard@male@idle_a",
        anim = "idle_c",
    },
    scenario = "WORLD_HUMAN_CLIPBOARD",
}

Config.VehicleSpawnPoint = vector4(544.92, 93.55, 96.12, 70.0)

Config.VehicleModel = "faggio"
Config.DeleteVehicleOnJobEnd = true
Config.VehicleLivery = 1

Config.MinPayment = 150
Config.MaxPayment = 300
Config.XPPerDelivery = 5
Config.PaymentType = "cash"

Config.MinDeliveries = 3
Config.MaxDeliveries = 8
Config.DeliveryTime = 5000

Config.UseBlip = true
Config.BlipSprite = 267
Config.BlipColor = 1
Config.BlipScale = 0.8

Config.DeliveryBlipSprite = 162
Config.DeliveryBlipColor = 1
Config.DeliveryBlipScale = 0.8

Config.UseUI = true
Config.UIKey = 'E'
Config.AllowUICloseWithEscape = true
Config.AutoCloseUIOnDistance = true
Config.MaxUIDistance = 3.0
Config.DisableUIOnStartup = true

Config.UseAnimation = true
Config.AnimDict = "mp_common"
Config.AnimName = "givetake1_a"
Config.AnimFlag = 8

Config.DeliveryHomes = {
    vector4(-169.86, 285.34, 93.76, 3.74)
}

Config.Messages = {
    ['job_started'] = "Pizza teslimatçısı olarak işe başladın. %s teslimat yapacaksın.",
    ['job_ended'] = "Pizza teslimatçılığı işini bıraktın.",
    ['new_delivery'] = "Yeni teslimat noktası haritan üzerinde işaretlendi.",
    ['delivery_complete'] = "Teslimat tamamlandı! $%s kazandın.",
    ['exit_vehicle'] = "Araçtan inerek %s tuşuna bas",
    ['deliver_pizza'] = "%s - Kapıya Pizza Teslim Et",
    ['delivering_pizza'] = "Pizza teslim ediliyor...",
    ['cancelled'] = "İşlem iptal edildi.",
    ['start_job'] = "%s - Pizza Kuryeliğine Başla",
    ['end_job'] = "%s - Pizza Kuryeliğini Bırak",
    ['not_in_vehicle'] = "Doğru araçta değilsin!",
    ['not_your_vehicle'] = "Bu araç sana ait değil!",
    ['all_deliveries_done'] = "Tüm teslimatları tamamladın! Mesleği bitirmek için merkeze dön.",
    ['no_bag'] = "Pizza çantası olmadan teslimat yapamazsın!",
    ['vehicle_spawned'] = "Pizza scooter'ı hazır. İyi teslimatlar!"
}

Config.UseMarkers = true
Config.MarkerType = 2
Config.MarkerSize = {x = 0.3, y = 0.3, z = 0.3}
Config.MarkerColor = {r = 255, g = 0, b = 0, a = 155}

Config.RequireBag = false
Config.BagItem = "pizza_bag"
Config.GiveBagOnJobStart = true
Config.ReturnBagOnJobEnd = true

Config.CustomVehicleSettings = {
    fuelLevel = 100,
    platePrefix = "PIZZA",
    plateNumbers = true,
}

Config.TargetSettings = {
    jobStartIcon = "fas fa-pizza-slice",
    jobStartLabel = "Pizza Teslimatçılığına Başla",
    jobEndIcon = "fas fa-pizza-slice",
    jobEndLabel = "Pizza Teslimatçılığını Bırak",
    deliveryIcon = "fas fa-pizza-slice",
    deliveryLabel = "Pizza Teslim Et",
}

Config.ChargeVehicleFee = false
Config.VehicleFee = 200

Config.TrackPerformance = false
Config.PerformanceBonus = {
    enabled = false,
    minCompletedDeliveries = 5,
    bonusAmount = 500,
    timeLimit = 15
}

Config.PreventsResourceConflicts = true
Config.ForceCloseUIOnError = true
Config.DebugMode = false