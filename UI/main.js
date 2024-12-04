window.addEventListener('message', function(event) {
    var item = event.data;
    if (item.type === "ShowGarage") {
        var Garage = item.garage
        var VehicleDisplay = $(".Garage").find(".VehicleDisplay");
        if (item.bgImage != null && item.bgImage != "") { 
            $(".BG_Image").show()
            $(".BG_Image").attr("src", item.bgImage);
        }
        else{
            $(".BG_Image").hide()
            $(".Main").css("background", "radial-gradient(50% 50% at 50% 50%, rgba(115, 115, 115, 0.9) 0%, rgba(60, 59, 59, 0.9) 100%);");
        }
        $('.Main').fadeIn("slow");
        $('.Garage').show();
        $('.Header-Text').text(`${item.name.toUpperCase()} GARAGE`);
        $.each(Garage.vehicles, function(id, vehicle){
            if (vehicle.out === true) {
                VehicleDisplay.append(`
                    <div class="VehicleCard" style = "display: none;">
                        <div class = "VehicleName">
                            <p>${vehicle.name.toUpperCase()}</p>
                        </div>
                        <div class="VehicleImage">
                            <img src="./vehicleimage/${vehicle.model}.png" alt="">
                        </div>
                        <div class="VehicleInfo">
                            <p class="VehicleFuel">FUEL: ${Math.round(vehicle.props.vehProps.fuelLevel) || "N/A"}</p>
                            <div class="ColorShow">
                                <p class="VehicleColor">COLOR:</p>
                                <div class="ColorBox" style = "background:rgb(${vehicle.props.rgb.r},${vehicle.props.rgb.g},${vehicle.props.rgb.b});"></div>
                            </div>
                            <button class="UnusableButton">ALREADY OUT</button>
                        </div>
                    </div>  
                `);
                $(".VehicleDisplay").find(".VehicleCard").fadeIn(1000);
            }else{
                VehicleDisplay.append(`
                    <div class="VehicleCard" vehicleID = '${vehicle.id}' style = "display: none;" >
                        <div class = "VehicleName">
                            <p>${vehicle.name.toUpperCase()}</p>
                        </div>
                        <div class="VehicleImage">
                            <img src="./vehicleimage/${vehicle.model}.png" alt="">
                        </div>
                        <div class="VehicleInfo">
                            <p class="VehicleFuel">FUEL: ${Math.round(vehicle.props.vehProps.fuelLevel) || "N/A"}</p>
                            <div class="ColorShow">
                                <p class="VehicleColor">COLOR:</p>
                                <div class="ColorBox" style = "background:rgb(${vehicle.props.rgb.r},${vehicle.props.rgb.g},${vehicle.props.rgb.b});"></div>
                            </div>
                            <button class="Button" id="VehicleUse" vehicleModel = '${vehicle.model}' vehicleID = '${vehicle.id}' garageName = '${Garage.name}'>TAKE OUT</button>
                        </div>
                    </div>  
                `);
                $(".VehicleDisplay").find(".VehicleCard").fadeIn(1000);
            }
        });
    }
    if (item.type === "ShowCreator"){
        $('.Creator').fadeIn("slow");
    }
    if (item.type === "LocationPlace"){
        if (item.open === true){
            $('.locationPlacer').show();
            $('.locationPlacer-element').text(item.text);
        }
        else{
            $('.locationPlacer').hide();
            $('.locationPlacer-element').text("N/A");
        }
    }
});

function resetUI(){
    $('.Garage').hide();
    $('#gangNameInputBox').val("");
    $('#leaderIDInputBox').val("");
    $('#gangInitColorPicker').val("#FFFFFF")
    var VehicleDisplay = $(".Garage").find(".VehicleDisplay");
    VehicleDisplay.empty();
}


$(document).on('click', '.ExitButton', function() {
    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
        action: "CloseUI"
    }));
    resetUI();
    $('.Main').hide();
    $('.Creator').hide();
});

$(document).on('click', '#VehicleUse', function() {
    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
        action: "CloseUI"
    }));
    resetUI();
    $('.Main').hide();
    var ID = $(this).attr("vehicleID");
    var model = $(this).attr("vehicleModel");
    var garage = $(this).attr("garageName");
        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: "TakeOutVehicle",
            vehicleID: ID,
            model: model,
            garageName: garage,
        }));
});

function hideInvalidInput() {
    $('.CreateInvalidInput').hide()
}

$(document).on('click', '#gangCreate', function() {
    var gangName = $('#gangNameInputBox').val();
    var leaderId = $('#leaderIDInputBox').val();
    var color= $('#gangInitColorPicker').val();
    $.post(`https://${GetParentResourceName()}/gangCreation`, JSON.stringify({
        action: "checkExisting",
        gangName: gangName,
    })).done(function(data){
        if (data.status) {
            $('.CreateInvalidInput').show()
            $('.InputInvalid-Text').text("GANG NAME ALREADY IN USE");
            setTimeout(hideInvalidInput, 2000);
        }
        else{
            $('.CreateInvalidInput').hide()
            $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
                action: "CloseUI"
            }));
            resetUI();
            $('.Creator').hide();
            $.post(`https://${GetParentResourceName()}/gangCreation`, JSON.stringify({
                action: "beginLocationSelection",
                gangName: gangName,
                leaderId: leaderId,
                r: parseInt(color.substr(1, 2), 16),
                g: parseInt(color.substr(3, 2), 16),
                b: parseInt(color.substr(5, 2), 16)
            }));
        }
    });
});



