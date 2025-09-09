local QBCore = exports['qb-core']:GetCoreObject()

--  Contact delen
RegisterNetEvent("lb-phone:addon:shareContact", function(targetID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetID)
    if not TargetPlayer then
        return exports["lb-phone"]:SendNotification(src, {
            app = "Settings",
            title = "Onmogelijk",
            content = "Speler niet gevonden",
        })
    end

    local spelerNaam = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local citizenid = Player.PlayerData.citizenid
    local targetCitizenid = TargetPlayer.PlayerData.citizenid

    --  Telefoonnummer deler
    local playerPhone = MySQL.single.await(
        "SELECT phone_number FROM phone_phones WHERE owner_id = ? LIMIT 1",
        { citizenid }
    )
    if not playerPhone then
        return exports["lb-phone"]:SendNotification(src, {
            app = "Settings",
            title = "Onmogelijk",
            content = "Je hebt geen telefoon",
        })
    end
    local telefoonNummer = tostring(playerPhone.phone_number)

 
    local targetPhone = MySQL.single.await(
        "SELECT phone_number FROM phone_phones WHERE owner_id = ? LIMIT 1",
        { targetCitizenid }
    )
    if not targetPhone then
        return exports["lb-phone"]:SendNotification(src, {
            app = "Settings",
            title = "Onmogelijk",
            content = "De ontvanger heeft geen telefoon",
        })
    end
    local targetTelefoonNummer = tostring(targetPhone.phone_number)

    --  Check of contact al bestaat
    local contactCheck = MySQL.single.await(
        "SELECT * FROM phone_phone_contacts WHERE contact_phone_number = ? AND phone_number = ?",
        { telefoonNummer, targetTelefoonNummer }
    )
    if contactCheck then
        return exports["lb-phone"]:SendNotification(src, {
            app = "Settings",
            title = "Bestaat al",
            content = "De ontvanger heeft jouw nummer al in zijn contacten",
        })
    end

    --  Voeg contact toe
    exports["lb-phone"]:AddContact(targetTelefoonNummer, {
        number = telefoonNummer,
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname
    })

    --  Bericht naar ontvanger
    exports["lb-phone"]:SendMessage(
        telefoonNummer,
        targetTelefoonNummer,
        "Hoi! " .. spelerNaam .. " heeft zijn/haar contact met je gedeeld.",
        nil,
        nil
    )

    --  Notificatie naar deler
    exports["lb-phone"]:SendNotification(src, {
        app = "Settings",
        title = "Gelukt",
        content = "Je contactgegevens zijn gedeeld",
    })
end)

 
