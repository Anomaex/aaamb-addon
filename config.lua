--
-- Addon configurations, global methods and variables
--


AAAMB = {
    char_names = {
        tank = "Initiator",
        healer = "Silini",
        damagers = {
            "Mieko",
            "Naoni",
            "Ionari"
        }
    },
    Methods = {
        KMB = {},
        Templates = {
            Paladin = {
                Damager = {}
            },
            Druid = {
                Healer = {}
            }
        }
    },
    tank = nil,
    healer = nil,
    damagers = nil,
    follow = false,
    follow_paused = false,
    stay_at_place = false,
    click_to_move = false
}
