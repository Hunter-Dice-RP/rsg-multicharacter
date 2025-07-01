/* // SCRIPT.JS - "EL ESCRITORIO DEL INVESTIGADOR"
var audioPlayer = new Audio();
var musicConfig = [];
var currentSongIndex = -1;
var isPlaying = false;

function loadAndPlaySong(index) {
    if (!musicConfig || musicConfig.length === 0 || index < 0 || index >= musicConfig.length) {
        return;
    }

    currentSongIndex = index;
    const song = musicConfig[index];
    if (!song) {
        return;
    }

    audioPlayer.src = song.path;
    audioPlayer.volume = $('#volume-slider').val();

    var playPromise = audioPlayer.play();
    if (playPromise !== undefined) {
        playPromise.then(_ => {
            $('#current-song-label').text(song.label);
            $('#music-play-pause').text('pause');
            isPlaying = true;
        }).catch(error => {
            $('#current-song-label').text('Error de archivo');
            $('#music-play-pause').text('play_arrow');
            isPlaying = false;
        });
    }
}

function togglePlayPause() {
    if (isPlaying) {
        audioPlayer.pause();
        $('#music-play-pause').text('play_arrow');
        isPlaying = false;
    } else {
        if (currentSongIndex === -1) {
            if (musicConfig.length > 0) {
                let randomIndex = Math.floor(Math.random() * musicConfig.length);
                loadAndPlaySong(randomIndex);
            }
        } else {
            audioPlayer.play().catch(error => console.error("Error al reanudar:", error));
            $('#music-play-pause').text('pause');    // Al reanudar, nos aseguramos de que el estado de la UI sea correcto.
            isPlaying = true;
        }
    }
}

function playNext() {
    if (!musicConfig || musicConfig.length === 0) return;
    let nextIndex = (currentSongIndex + 1) % musicConfig.length;
    loadAndPlaySong(nextIndex);
}

function playPrev() {
    if (!musicConfig || musicConfig.length === 0) return;
    let prevIndex = (currentSongIndex - 1 + musicConfig.length) % musicConfig.length;
    loadAndPlaySong(prevIndex);
}

function stopMusic() {
    if (isPlaying) {
        let currentVolume = audioPlayer.volume;
        let fadeOutInterval = setInterval(function() {
            currentVolume -= 0.1;
            if (currentVolume > 0) {
                audioPlayer.volume = Math.max(0, currentVolume);
            } else {
                clearInterval(fadeOutInterval);
                audioPlayer.pause();
                audioPlayer.currentTime = 0;
                audioPlayer.src = "";

                $('#current-song-label').text('Silencio...');
                $('#music-play-pause').text('play_arrow');
                isPlaying = false;
                currentSongIndex = -1;
            }
        }, 50);
    }
}

function setMusicConfig(config) {
    if (typeof config === 'string') {
        try {
            musicConfig = JSON.parse(config);
        } catch (e) {
            musicConfig = [];
        }
    } else {
        musicConfig = config || [];
    }
    
    console.log(`UI iniciada. ${musicConfig.length} canciones cargadas.`);
}

window.musicPlayer = {
    loadAndPlaySong,
    togglePlayPause,
    playNext,
    playPrev,
    stopMusic,
    setMusicConfig,
    audioPlayer: audioPlayer
};

audioPlayer.addEventListener('ended', playNext); // Pasa a la siguiente canción automáticamente */