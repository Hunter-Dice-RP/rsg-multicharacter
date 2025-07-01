// // SCRIPT.JS - "EL ESCRITORIO DEL INVESTIGADOR"
// var selectedChar = null;
// var NChar = null;

// var WelcomePercentage = "30vh"

// qbMultiCharacters = {}
// var Loaded = false;

// $(document).ready(function (){
//     window.addEventListener('message', function (event) {
//         var data = event.data;

//         if (data.action == "ui") {
//             NChar = data.nChar;
//             if (data.toggle) {
//                 $('.container').show();
//                 $(".welcomescreen").fadeIn(150);
//                 qbMultiCharacters.resetAll();

//                 var originalText = "Retrieving player data";
//                 var loadingProgress = 0;
//                 var loadingDots = 0;
//                 $("#loading-text").html(originalText);
//                 var DotsInterval = setInterval(function() {
//                     $("#loading-text").append(".");
//                     loadingDots++;
//                     loadingProgress++;
//                     if (loadingProgress == 3) {
//                         originalText = "Validating player data"
//                         $("#loading-text").html(originalText);
//                     }
//                     if (loadingProgress == 4) {
//                         originalText = "Retrieving characters"
//                         $("#loading-text").html(originalText);
//                     }
//                     if (loadingProgress == 6) {
//                         originalText = "Validating characters"
//                         $("#loading-text").html(originalText);
//                     }
//                     if(loadingDots == 4) {
//                         $("#loading-text").html(originalText);
//                         loadingDots = 0;
//                     }
//                 }, 500);

//                 setTimeout(function(){
//                     setCharactersList()
//                     $.post('https://rsg-multicharacter/setupCharacters');
//                     setTimeout(function(){
//                         clearInterval(DotsInterval);
//                         loadingProgress = 0;
//                         originalText = "Retrieving data";
//                         $(".welcomescreen").fadeOut(150);
//                         qbMultiCharacters.fadeInDown('.character-info', '20%', 400);
//                         qbMultiCharacters.fadeInDown('.characters-list', '20%', 400);
//                         $.post('https://rsg-multicharacter/removeBlur');
//                     }, 2000);
//                 }, 2000);
//             } else {
//                 $('.container').fadeOut(250);
//                 qbMultiCharacters.resetAll();
//             }
//         }

//         if (data.action == "setupCharacters") {
//             setupCharacters(event.data.characters)
//         }

//         if (data.action == "setupCharInfo") {
//             setupCharInfo(event.data.chardata)
//         }
//     });

//     $('.datepicker').datepicker();
// });

// $('.continue-btn').click(function(e){
//     e.preventDefault();
// });

// $('.disconnect-btn').click(function(e){
//     e.preventDefault();

//     $.post('https://rsg-multicharacter/closeUI');
//     $.post('https://rsg-multicharacter/disconnectButton');
// });

// function setupCharInfo(cData) {
//     if (cData == 'empty') {
//         $('.character-info-valid').html('<span id="no-char">The selected character slot is not in use yet.<br><br>This character doesn\'t have information yet.</span>');
//     } else {
//         var gender = "Man"
//         if (cData.charinfo.gender == 1) { gender = "Woman" }
//         $('.character-info-valid').html(
//         '<div class="character-info-box"><span id="info-label">Name: </span><span class="char-info-js">'+cData.charinfo.firstname+' '+cData.charinfo.lastname+'</span></div>' +
//         '<div class="character-info-box"><span id="info-label">Birth date: </span><span class="char-info-js">'+cData.charinfo.birthdate+'</span></div>' +
//         '<div class="character-info-box"><span id="info-label">Nationality: </span><span class="char-info-js">'+cData.charinfo.nationality+'</span></div>' +
//         '<div class="character-info-box"><span id="info-label">Job: </span><span class="char-info-js">'+cData.job.label+'</span></div>' +
//         '<div class="character-info-box"><span id="info-label">Cash: </span><span class="char-info-js">&#36; '+cData.money.cash+'</span></div>');
//     }
// }

// function setupCharacters(characters) {
//     $.each(characters, function(index, char){
//         $('#char-'+char.cid).html("");
//         $('#char-'+char.cid).data("citizenid", char.citizenid);
//         setTimeout(function(){
//             $('#char-'+char.cid).html('<span id="slot-name">'+char.charinfo.firstname+' '+char.charinfo.lastname+'<span id="cid">' + char.citizenid + '</span></span>');
//             $('#char-'+char.cid).data('cData', char)
//             $('#char-'+char.cid).data('cid', char.cid)
//         }, 100)
//     })
// }

// $(document).on('click', '#close-log', function(e){
//     e.preventDefault();
//     selectedLog = null;
//     $('.welcomescreen').css("filter", "none");
//     $('.server-log').css("filter", "none");
//     $('.server-log-info').fadeOut(250);
//     logOpen = false;
// });

// $(document).on('click', '.character', function(e) {
//     var cDataPed = $(this).data('cData');
//     e.preventDefault();
//     if (selectedChar === null) {
//         selectedChar = $(this);
//         if ((selectedChar).data('cid') == "") {
//             $(selectedChar).addClass("char-selected");
//             setupCharInfo('empty')
//             $("#play-text").html("Create");
//             $("#play").css({"display":"block"});
//             $("#delete").css({"display":"none"});
//             $.post('https://rsg-multicharacter/cDataPed', JSON.stringify({
//                 cData: cDataPed
//             }));
//         } else {
//             $(selectedChar).addClass("char-selected");
//             setupCharInfo($(this).data('cData'))
//             $("#play-text").html("Play");
//             $("#delete-text").html("Delete");
//             $("#play").css({"display":"block"});
//             $("#delete").css({"display":"block"});
//             $.post('https://rsg-multicharacter/cDataPed', JSON.stringify({
//                 cData: cDataPed
//             }));
//         }
//     } else if ($(selectedChar).attr('id') !== $(this).attr('id')) {
//         $(selectedChar).removeClass("char-selected");
//         selectedChar = $(this);
//         if ((selectedChar).data('cid') == "") {
//             $(selectedChar).addClass("char-selected");
//             setupCharInfo('empty')
//             $("#play-text").html("Register");
//             $("#play").css({"display":"block"});
//             $("#delete").css({"display":"none"});
//             $.post('https://rsg-multicharacter/cDataPed', JSON.stringify({
//                 cData: cDataPed
//             }));
//         } else {
//             $(selectedChar).addClass("char-selected");
//             setupCharInfo($(this).data('cData'))
//             $("#play-text").html("Play");
//             $("#delete-text").html("Delete");
//             $("#play").css({"display":"block"});
//             $("#delete").css({"display":"block"});
//             $.post('https://rsg-multicharacter/cDataPed', JSON.stringify({
//                 cData: cDataPed
//             }));
//         }
//     }
// });

// var entityMap = {
//     '&': '&amp;',
//     '<': '&lt;',
//     '>': '&gt;',
//     '"': '&quot;',
//     "'": '&#39;',
//     '/': '&#x2F;',
//     '': '&#x60;',
//     '=': '&#x3D;'
// };

// function escapeHtml(string) {
//     return String(string).replace(/[&<>"'=/]/g, function (s) {
//         return entityMap[s];
//     });
// }
// function hasWhiteSpace(s) {
//     return /\s/g.test(s);
//   }
// $(document).on('click', '#create', function (e) {
//     e.preventDefault();

//     let cid = escapeHtml($(selectedChar).attr('id').replace('char-', ''))

//     $.post('https://rsg-multicharacter/createNewCharacter', JSON.stringify({
//         cid: cid,
//     }));
//     $(".container").fadeOut(150);
//     $('.characters-list').css("filter", "none");
//     $('.character-info').css("filter", "none");
//     qbMultiCharacters.fadeOutDown('.character-register', '125%', 400);
//     refreshCharacters()
// });

// $(document).on('click', '#accept-delete', function(e){
//     $.post('https://rsg-multicharacter/removeCharacter', JSON.stringify({
//         citizenid: $(selectedChar).data("citizenid"),
//     }));
//     $('.character-delete').fadeOut(150);
//     $('.characters-block').css("filter", "none");
//     refreshCharacters();
// });

// $(document).on('click', '#cancel-delete', function(e){
//     e.preventDefault();
//     $('.characters-block').css("filter", "none");
//     $('.character-delete').fadeOut(150);
// });

// function setCharactersList() {
//     var htmlResult = '<div class="character-list-header"><p>My Characters</p></div>'
//     for (let i = 1; i <= NChar; i++) {
//         htmlResult += '<div class="character" id="char-'+ i +'" data-cid=""><span id="slot-name">Empty Slot<span id="cid"></span></span></div>'
//     }
//     htmlResult += '<div class="character-btn" id="play"><p id="play-text">Select a character</p></div><div class="character-btn" id="delete"><p id="delete-text">Select a character</p></div>'
//     $('.characters-list').html(htmlResult)
// }

// function refreshCharacters() {
//     var htmlResult = ''
//     for (let i = 1; i <= NChar; i++) {
//         htmlResult += '<div class="character" id="char-'+ i +'" data-cid=""><span id="slot-name">Empty Slot<span id="cid"></span></span></div>'
//     }

//     htmlResult += '<div class="character-btn" id="play"><p id="play-text">Select a character</p></div><div class="character-btn" id="delete"><p id="delete-text">Select a character</p></div>'
//     $('.characters-list').html(htmlResult)

//     setTimeout(function(){
//         $(selectedChar).removeClass("char-selected");
//         selectedChar = null;
//         $.post('https://rsg-multicharacter/setupCharacters');
//         $("#delete").css({"display":"none"});
//         $("#play").css({"display":"none"});
//         qbMultiCharacters.resetAll();
//     }, 100)
// }

// $("#close-reg").click(function (e) {
//     e.preventDefault();
//     $('.characters-list').css("filter", "none")
//     $('.character-info').css("filter", "none")
//     qbMultiCharacters.fadeOutDown('.character-register', '125%', 400);
// })

// $("#close-del").click(function (e) {
//     e.preventDefault();
//     $('.characters-block').css("filter", "none");
//     $('.character-delete').fadeOut(150);
// })

// $(document).on('click', '#play', function(e) {
//     e.preventDefault();
//     var charData = $(selectedChar).data('cid');

//     if (selectedChar !== null) {
//         if (charData !== "") {
//             $.post('https://rsg-multicharacter/selectCharacter', JSON.stringify({
//                 cData: $(selectedChar).data('cData')
//             }));
//             setTimeout(function(){
//                 qbMultiCharacters.fadeOutDown('.characters-list', "-40%", 400);
//                 qbMultiCharacters.fadeOutDown('.character-info', "-40%", 400);
//                 qbMultiCharacters.resetAll();
//             }, 1500);
//         } else {
//             $('.characters-list').css("filter", "blur(2px)")
//             $('.character-info').css("filter", "blur(2px)")
//             qbMultiCharacters.fadeInDown('.character-register', '25%', 400);
//         }
//     }
// });

// $(document).on('click', '#delete', function(e) {
//     e.preventDefault();
//     var charData = $(selectedChar).data('cid');

//     if (selectedChar !== null) {
//         if (charData !== "") {
//             $('.characters-block').css("filter", "blur(2px)")
//             $('.character-delete').fadeIn(250);
//         }
//     }
// });

// qbMultiCharacters.fadeOutUp = function(element, time) {
//     $(element).css({"display":"block"}).animate({top: "-80.5%",}, time, function(){
//         $(element).css({"display":"none"});
//     });
// }

// qbMultiCharacters.fadeOutDown = function(element, percent, time) {
//     if (percent !== undefined) {
//         $(element).css({"display":"block"}).animate({top: percent,}, time, function(){
//             $(element).css({"display":"none"});
//         });
//     } else {
//         $(element).css({"display":"block"}).animate({top: "103.5%",}, time, function(){
//             $(element).css({"display":"none"});
//         });
//     }
// }

// qbMultiCharacters.fadeInDown = function(element, percent, time) {
//     $(element).css({"display":"block"}).animate({top: percent,}, time);
// }

// qbMultiCharacters.resetAll = function() {
//     $('.characters-list').hide();
//     $('.characters-list').css("top", "-40");
//     $('.character-info').hide();
//     $('.character-info').css("top", "-40");
//     $('.welcomescreen').css("top", WelcomePercentage);
//     $('.server-log').show();
//     $('.server-log').css("top", "25%");
// }

// SCRIPT.JS -  "EL ESCRITORIO DEL INVESTIGADOR"
var selectedChar = null;
var NChar = null;

function buildToolkit(panelConfig) {
    const toolkitContainer = $('.agent-toolkit');
    const panelsWrapper = $('.investigation-panels-wrapper');
    toolkitContainer.empty();
    panelsWrapper.empty();

    let menuItems = '';
    if (panelConfig.telegrams.enabled) menuItems += `<div class="page-marker" data-panel="telegram-panel" title="${panelConfig.telegrams.title}"><span class="material-icons">${panelConfig.telegrams.icon}</span><div class="notification-dot" style="display:none;"></div></div>`;
    if (panelConfig.dossier.enabled) menuItems += `<div class="page-marker" data-panel="investigation-dossier" title="${panelConfig.dossier.title}"><span class="material-icons">${panelConfig.dossier.icon}</span></div>`;
    if (panelConfig.outfits.enabled) menuItems += `<div class="page-marker" data-panel="outfit-catalog-panel" title="${panelConfig.outfits.title}"><span class="material-icons">${panelConfig.outfits.icon}</span></div>`;
    if (panelConfig.music.enabled) menuItems += `<div class="page-marker" data-panel="music-note-panel" title="${panelConfig.music.title}"><span class="material-icons">${panelConfig.music.icon}</span></div>`;

    const toolkit = `
        <!-- Control toolkit -->
        <div class="page-marker" id="main-marker" title="Herramientas">
            <span class="material-icons">more_horiz</span>
        </div>
        <div class="marker-menu" style="display: none;">${menuItems}</div>`;

    const panels = `
        <!-- Control telegrams -->
        <div class="telegram-panel investigation-panel draggable-panel" style="display: none;"><h4>Últimos Telegramas</h4><div id="telegram-list"></div></div>
        
        <!-- Control investigation -->
        <div class="investigation-dossier investigation-panel draggable-panel" style="display: none;">
            <div class="wanted-stamp" style="display: none;">SE BUSCA</div>
            <div class="dossier-header">Ficha de Filiación</div>
            <div class="dossier-content">
                <!-- Bio info -->
                <div class="dossier-item"><span class="dossier-label">Nº de Ficha:</span><span id="info-fingerprint">N/A</span></div>
                <div class="dossier-item"><span class="dossier-label">Estado Legal:</span><span id="info-status">N/A</span></div>

                <!-- Bio Houses -->
                <div class="dossier-item dossier-list-item">
                    <span class="dossier-label">Propiedades Registradas:</span>
                    <ul id="info-house-list"><li>Ninguna conocida</li></ul>
                </div>
                <!-- Bio Horse -->
                <div class="dossier-item dossier-list-item">
                    <span class="dossier-label">Corceles:</span>
                    <ul id="info-horse-list">
                        <!-- Los caballos se insertarán aquí -->
                        <li>Sin registrar</li>
                    </ul>
                </div>
                <!-- Bio Companion -->
                <div class="dossier-item dossier-list-item">
                    <span class="dossier-label">Compañeros Fieles:</span>
                    <ul id="info-companion-list">
                        <li>Ninguno conocido</li>
                    </ul>
                </div>
                <!-- Bio -->
                <div class="dossier-item bio"><span class="dossier-label">Observaciones del Agente:</span><div id="char-bio-text"></div></div>
            </div>
        </div>

        <!-- Control outfit -->
        <div class="outfit-catalog-panel investigation-panel draggable-panel" style="display: none;">
            <h4>Catálogo de Atuendos</h4>
            <ul id="outfit-list"></ul>
            <!-- <h4 class="panel-subtitle">Apariencias Guardadas</h4>
            <ul id="skin-list"></ul> -->
            <p id="outfit-confirmation" style="display:none;"></p>
        </div>

        <!-- Control music -->
        <div class="music-note-panel investigation-panel draggable-panel" style="display: none;">
            <div class="now-playing">
                <span class="material-icons">audiotrack</span>
                <span id="current-song-label">Silencio...</span>
            </div>
            <div>
                <div class="player-controls">
                    <span class="material-icons" id="music-prev">skip_previous</span>
                    <span class="material-icons" id="music-play-pause">play_arrow</span> <!-- Cambiará a 'pause' <h4>Melodías del Saloon</h4>-->
                    <span class="material-icons" id="music-next">skip_next</span>
                    <span class="material-icons">volume_down</span>
                    <input type="range" id="volume-slider" min="0" max="1" step="0.05" value="0.5">
                </div>
            </div>
        </div>`;
    
    toolkitContainer.html(toolkit);
    panelsWrapper.html(panels);
    // Elimina paneles antiguos antes de añadir nuevos para evitar duplicados
    //$('.investigation-panel').remove();
    //$('body').append(panels);

}

function setCharactersList() { let charactersHtml = ''; for (let i = 1; i <= NChar; i++) { charactersHtml += `<div class="character" id="char-${i}" data-cid=""><span id="slot-name">Expediente Vacío<span id="cid"></span></span></div>`; } $('.characters-list').html(charactersHtml); }

function setupCharacters(characters) { 
    $('.characters-list').empty();
    for (let i = 1; i <= NChar; i++) {
        let char = characters.find(c => c.cid == i);
        let html;
        if (char && char.charinfo) {
            html = `<div class="character" id="char-${i}" data-cid="${i}"><span id="slot-name">${char.charinfo.firstname} ${char.charinfo.lastname}<span id="cid">${char.citizenid}</span></span></div>`;
            $('.characters-list').append(html);
            $('#char-' + i).data({"citizenid": char.citizenid, 'cData': char, 'cid': char.cid});
        } else {
            html = `<div class="character" id="char-${i}" data-cid=""><span id="slot-name">Expediente Vacío<span id="cid"></span></span></div>`;
            $('.characters-list').append(html);
        }
    }
}

function setupCharInfo(cData, isInitial = false) {
    const infoPage = $('.character-info');
    const listPage = $('.characters-list-page');
    let char = cData.data;
    let newContentHtml = '';

    // --- Paso 1: Limpiar siempre cualquier modal anterior ---
    // Esto previene que se acumulen modales si el usuario hace clics rápidos.
    $('.temp-modal-container').remove();

    // --- Paso 2: Preparar el contenido HTML según el tipo ---
    switch (cData.type) {
        case 'delete':
            newContentHtml = `<div class="modal-content-wrapper"><p id="char-info-titel">Archivar Expediente</p><p>¿Estás seguro de que quieres archivar a este personaje? Esta acción es irreversible.</p><div class="modal-actions"><div id="cancel-action" class="modal-btn cancel">Cancelar</div><div id="accept-delete" class="modal-btn confirm">Confirmar</div></div></div>`;
            break;
        case 'create':
            newContentHtml = `<div class="modal-content-wrapper"><p id="char-info-titel">Nuevo Forajido</p><p>Un nuevo rostro llega al Oeste. ¿Estás listo para escribir su leyenda?</p><div class="modal-actions"><div id="cancel-action" class="modal-btn cancel cancel-action-trigger">Volver</div><div id="create" class="modal-btn create-confirm">Iniciar Creación</div></div></div>`;
            break;
        case 'info':
            if (char && char.charinfo) {
                newContentHtml = `<p id="char-info-titel">${char.charinfo.firstname}'s Dossier</p><div class="character-info-valid"><div class="character-info-box"><span id="info-label">Nombre:</span><span class="char-info-js">${char.charinfo.firstname} ${char.charinfo.lastname}</span></div><div class="character-info-box"><span id="info-label">Nacimiento:</span><span class="char-info-js">${char.charinfo.birthdate}</span></div><div class="character-info-box"><span id="info-label">Origen:</span><span class="char-info-js">${char.charinfo.nationality}</span></div><div class="character-info-box"><span id="info-label">Oficio:</span><span class="char-info-js">${char.job.label}</span></div><div class="character-info-box"><span id="info-label">Efectivo:</span><span class="char-info-js">$ ${char.money.cash}</span></div></div>`;
            } else {
                newContentHtml = `<p id="char-info-titel">Anotaciones</p><span id="no-char">Selecciona un expediente de la lista.</span>`;
            }
            break;
        default: // 'empty'
            newContentHtml = `<p id="char-info-titel">Anotaciones</p><span id="no-char">Selecciona un expediente de la lista, o elige un espacio vacío para crear una nueva leyenda.</span>`;
            break;
    }

    // --- Paso 3: Renderizar en el lugar correcto y gestionar la visibilidad de la UI ---
    if (cData.type === 'create' || cData.type === 'delete') {
        // --- ESTADO B: Estamos mostrando un modal en la página de la derecha ---
        
        // Ocultar el contenido original de la página de lista (botones, lista, header).
        // .stop(true, true) previene errores de animación por clics rápidos.
        listPage.children().stop(true, true).fadeOut(200);

        // Crear y mostrar el modal temporal
        const modalHtml = $(`<div class="temp-modal-container" style="display:none;">${newContentHtml}</div>`);
        listPage.append(modalHtml);
        modalHtml.fadeIn(200);

    } else {
        // --- ESTADO A: Estamos mostrando información normal ---
        
        // Asegurarse de que el contenido de la página de lista (botones, lista, header) está visible.
        // CADA VEZ que se llama con 'info' o 'empty', esta línea se ejecuta, garantizando que los botones vuelven.
        listPage.children().stop(true, true).fadeIn(200);
        
        // Actualizar la página de información de la izquierda
        if (isInitial) {
            infoPage.html(newContentHtml);
        } else {
            infoPage.fadeOut(200, function() {
                $(this).html(newContentHtml).fadeIn(200);
            });
        }
    }
}

function startUI(panelConfig, musicConfigData) {

    window.musicPlayer.setMusicConfig(musicConfigData);
    buildToolkit(panelConfig); // Construye la interfaz con la config recibida

    // NUEVO: Lógica para hacer los paneles arrastrables en pantallas anchas
    const screenAspectRatio = window.innerWidth / window.innerHeight;
    if (screenAspectRatio > 2.0) { // Consideramos "ultrawide" un aspect ratio > 2:1 (ej. 21:9)
        $('.draggable-panel').draggable({
            containment: "parent" // Limita el arrastre al contenedor padre
        }).addClass('is-draggable');
    }

    $('.sketchbook-wrapper, .agent-toolkit').hide();
    $('.sketchbook-wrapper').removeClass('is-active is-open');
    $('.sketchbook').removeClass('is-open');
    clearInvestigationPanels();
    $('.sketchbook-wrapper').addClass('is-active').fadeIn(200);

    const loadingMessages = ["Reuniendo apuntes...", "Bocetando sospechosos...", "¡Listo!"];
    let messageIndex = 0;
    $('.loading-bar-progress').css('width', '0%');
    $('#loading-text').text(loadingMessages[messageIndex++]);
    const loadInterval = setInterval(() => {
        const currentWidth = parseFloat($('.loading-bar-progress').css('width')) / parseFloat($('.loading-bar-container').css('width')) * 100;
        const newWidth = Math.min(100, currentWidth + 25);
        $('.loading-bar-progress').css('width', newWidth + '%');
        if (messageIndex < loadingMessages.length) { $('#loading-text').text(loadingMessages[messageIndex++]); }
    }, 800);

    setCharactersList();
    $.post('https://rsg-multicharacter/setupCharacters');
    setupCharInfo({ type: 'empty' }, true);

    setTimeout(() => {
        clearInterval(loadInterval);
        $('.sketchbook').addClass('is-open');
        $('.agent-toolkit').fadeIn(500);
        $.post('https://rsg-multicharacter/removeBlur');
    }, 3200);
}

function updateInvestigationPanels(raw) {
    const data = raw.data || raw;

    if (!data || !selectedChar) {
        console.warn("[NUI] updateInvestigationPanels: No data or character selected.");
        return;
    }

    console.log('[NUI] Investigación recibida:', data);

    // Estatus legal
    $('.wanted-stamp').toggle(data.legal?.isWanted || false);
    $('#info-fingerprint').text(data.metadata?.fingerprint || 'N/A');
    $('#info-status').text(data.legal?.isWanted ? 'Buscado por la Ley' : 'Ciudadano');

    // Biografía
    const bioText = typeof data.bio === 'string'
        ? data.bio.replace(/\n/g, '<br>')
        : Array.isArray(data.bio)
            ? data.bio.join('<br><br>')
            : "No hay observaciones.";
    $('#char-bio-text').html(bioText);

    // Casas
    const houseList = $('#info-house-list').empty();
    if (Array.isArray(data.houses) && data.houses.length > 0) {
        data.houses.forEach(house => {
            const houseName = house.houseid || 'Propiedad';
            houseList.append(`<li>${houseName.charAt(0).toUpperCase() + houseName.slice(1)}</li>`);
        });
    } else {
        houseList.html('<li>Ninguna conocida</li>');
    }

    // Caballos
    const horseList = $('#info-horse-list').empty();
    if (Array.isArray(data.horses) && data.horses.length > 0) {
        data.horses.forEach(horse => {
            const horseName = horse.name || 'Caballo sin nombre';
            const horseXP = horse.horsexp || 0;
            horseList.append(`<li>${horseName} <span class="horse-xp">(XP: ${horseXP})</span></li>`);
        });
    } else {
        horseList.html('<li>Sin corceles notables.</li>');
    }

    // Compañeros
    const companionList = $('#info-companion-list').empty();
    if (Array.isArray(data.companions) && data.companions.length > 0) {
        data.companions.forEach(companion => {
            const companionName = companion.companiondata?.name || 'Compañero sin nombre';
            companionList.append(`<li>${companionName}</li>`);
        });
    } else {
        companionList.html('<li>Ninguno conocido</li>');
    }

    // Telegramas
    const telegramList = $('#telegram-list').empty();
    if (Array.isArray(data.telegrams) && data.telegrams.length > 0) {
        const hasUnread = data.telegrams.some(t => t.status === 0 || t.status === '0');
        $('.page-marker[data-panel="telegram-panel"] .notification-dot').toggle(hasUnread);
        data.telegrams.forEach(t => {
            telegramList.append(`
                <div class="telegram-item">
                    <strong>DE: ${t.sender || 'Anónimo'} | ASUNTO: ${t.subject || 'Sin Asunto'}</strong>
                    <p>${t.message || ''}</p>
                </div>`);
        });
    } else {
        telegramList.html('<p style="text-align:center; padding: 20px; font-style: italic;">Sin telegramas recientes.</p>');
        $('.page-marker[data-panel="telegram-panel"] .notification-dot').hide();
    }

    // Atuendos
    const outfitList = $('#outfit-list').empty();
    if (Array.isArray(data.outfits) && data.outfits.length > 0) {
        data.outfits.forEach(o => {
            outfitList.append(`<li class="outfit-item" data-outfit-name="${o.name}">${o.name}</li>`);
        });
    } else {
        outfitList.html('<li>Sin atuendos guardados.</li>');
    }

    // Skins
    const skinList = $('#skin-list').empty();
    if (Array.isArray(data.skins) && data.skins.length > 0) {
        data.skins.forEach((skin, index) => {
            skinList.append(`<li>Apariencia Guardada #${skin.id || (index + 1)}</li>`);
        });
    } else {
        skinList.html('<li>Sin apariencias guardadas.</li>');
    }
}

function clearInvestigationPanels() {
    $('.investigation-panel').hide();
    $('.marker-menu').hide();
    $('.page-marker').removeClass('active');
    $('.notification-dot').hide();
}

function closeMulticharacterUI() {
    stopMusic();
    $('.container').fadeOut(250, function() {
        clearInvestigationPanels();
        $('.sketchbook-wrapper').removeClass('is-active is-open');
        $('.agent-toolkit').hide();
    });
}

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        var data = event.data;
        switch (data.action) {
            case "ui":
                NChar = data.nChar;
                if (data.toggle) {
                    $('.container').fadeIn(250);
                    startUI(data.panelConfig, data.musicConfigData);
                } else {
                    closeMulticharacterUI();
                }
                break;
            case "setupCharacters":
                setupCharacters(data.characters);
                break;
            case "updateInvestigationData":
                console.log('Datos recibidos:', data.data);
                updateInvestigationPanels(data.data);
                break;
        }
    });

    $(document).on('click', '#music-play-pause', function() { window.musicPlayer.togglePlayPause(); });
    $(document).on('click', '#music-next', function() { window.musicPlayer.playNext(); });
    $(document).on('click', '#music-prev', function() { window.musicPlayer.playPrev(); });
    /*$(document).on('click', '#song-list li', function() { window.musicPlayer.playSong($(this).index()); });*/
    $(document).on('input', '#volume-slider', function() { 
        // Ajustamos el volumen directo en music.js
        if (window.musicPlayer && window.musicPlayer.audioPlayer) {
            window.musicPlayer.audioPlayer.volume = $(this).val();
        }
    });

    // 3. LISTENERS DE LA INTERFAZ DE INVESTIGACIÓN
    $(document).on('click', '#main-marker', function(e) {
        e.stopPropagation();
        const menu = $('.marker-menu');
        if (menu.is(':visible')) {
            menu.slideUp(200);
            $('.investigation-panel').fadeOut(200);
            $('.marker-menu .page-marker').removeClass('active');
        } else {
            menu.slideDown(200);
        }
    });

    $(document).on('click', '.marker-menu .page-marker', function(e) {
        e.stopPropagation();
        const panelClass = $(this).data('panel');
        $('.' + panelClass).fadeToggle(200);
        $(this).toggleClass('active');
        if (panelClass === 'telegram-panel' && selectedChar) {
            $(this).find('.notification-dot').fadeOut(200);
            let cData = selectedChar.data('cData');
            // Corregido para usar recipient desde cData si está disponible
            let recipient = cData?.charinfo?.firstname + ' ' + cData?.charinfo?.lastname;
            if (recipient) {
                $.post('https://rsg-multicharacter/markTelegramsRead', JSON.stringify({ recipient: recipient }));
            }
        }
    });

    $(document).on('click', '.outfit-item', function() {
        let outfitName = $(this).data('outfit-name');
        $('#outfit-confirmation').text(`Atuendo '${outfitName}' preparado.`).stop().fadeIn(200).delay(2500).fadeOut(200);
        // $.post('https://rsg-multicharacter/selectOutfit', JSON.stringify({ recipient: recipient }));
    });
    
    // 4. LISTENERS DE SELECCIÓN Y ACCIONES DE PERSONAJE
    $(document).on('click', '.character', function(e) {
        e.preventDefault();
        if ($(this).is(selectedChar)) return;
        if (selectedChar) { selectedChar.removeClass("char-selected"); }
        selectedChar = $(this).addClass("char-selected");
        let cData = selectedChar.data('cData') || null;
        let cid = selectedChar.data('cid');
        
        clearInvestigationPanels();
        setupCharInfo({ type: (cid ? 'info' : 'empty'), data: cData });
        $.post('https://rsg-multicharacter/cDataPed', JSON.stringify({ cData: cData }));

        if (cid) {
            $("#play").text("Jugar");
            $("#delete").show();
        } else {
            $("#play").text("Crear");
            $("#delete").hide();
        }
        $("#play").show();
    });

    $(document).on('click', '#play', function(e) { 
        e.preventDefault(); 
        if (!selectedChar) return; 
        if (selectedChar.data('cid')) {
            $.post('https://rsg-multicharacter/selectCharacter', JSON.stringify({ cData: $(selectedChar).data('cData') })); 
        } else { 
            setupCharInfo({ type: 'create' }); 
        } 
    });

    $(document).on('click', '#delete', function(e) {
        e.preventDefault(); 
        if (selectedChar && selectedChar.data('cid')) { 
            setupCharInfo({ type: 'delete', data: selectedChar.data('cData') }); 
        } 
    });

    $(document).on('click', '#create', function (e) {
        e.preventDefault();
        if (!selectedChar) return;
        let cid = selectedChar.attr('id').replace('char-', '');
        $.post('https://rsg-multicharacter/createNewCharacter', JSON.stringify({
            cid: cid
        }));
    });

    $(document).on('click', '#accept-delete', function(e){
        e.preventDefault();
        if (!selectedChar) return;
        $.post('https://rsg-multicharacter/removeCharacter', JSON.stringify({ citizenid: selectedChar.data("citizenid") }));
        
        // Limpia la UI después de borrar
        selectedChar.removeClass('char-selected').html('<span id="slot-name">Expediente Vacío<span id="cid"></span></span>').removeData('cid').removeData('cData').removeData('citizenid');
        selectedChar = null;
        $('#play, #delete').hide();
        setupCharInfo({ type: 'empty' }); 
        clearInvestigationPanels();
    });

    $(document).on('click', '#cancel-action, .cancel-action-trigger', function(e) {
        e.preventDefault();
        let cData = selectedChar ? selectedChar.data('cData') : null;
        let cid = selectedChar ? selectedChar.data('cid') : null;
        setupCharInfo({ type: (cid ? 'info' : 'empty'), data: cData });
    });
});