--
-- Addon configurations, global methods and variables
--


AAAMB = {
    char_names = {
        tank = "Initiator",
        healer = "Dropbop",
        damagers = {
            "Raifanzen",
            "Bashscript",
            "Goggi"
        }
    },
    Methods = {
        KMB = {},
        Templates = {
            Paladin = {
                Healer = {},
                Damager = {}
            }
        }
    },
    tank = nil,
    healer = nil,
    damagers = nil,
    follow = false,
    follow_paused = false,
    stay_at_place = false,
    click_to_move = false,
    health_percent = 100,
    mana_percent = 100
}
