//
//  PausedState.swift
//  RxAudioPlayerSM
//
//  Created by ankierman on 23/02/2018.
//  Copyright © 2018 raphael ankierman. All rights reserved.
//

import AVFoundation

final class PausedState: PlayerState {
    
    // MARK: - Input
    
    unowned var context: PlayerContext
    private var interruptionAudioService: ModernAVPlayerInterruptionAudioService

    // MARK: - Output
    
    var onInterruptionEnded: (() -> Void)? {
        didSet { interruptionAudioService.onInterruptionEnded = onInterruptionEnded }
    }
    
    // MARK: - Variable
    
    var type: ModernAVPlayer.State = .paused

    // MARK: Init
    
    init(context: PlayerContext,
         interruptionAudioService: ModernAVPlayerInterruptionAudioService = ModernAVPlayerInterruptionAudioService()) {
        LoggerInHouse.instance.log(message: "Init", event: .debug)
        self.context = context
        self.context.player.pause()
        self.interruptionAudioService = interruptionAudioService
    }
    
    deinit {
        LoggerInHouse.instance.log(message: "Deinit", event: .debug)
    }
    
    // MARK: - Shared actions

    func loadMedia(media: PlayerMedia, shouldPlaying: Bool) {
        let state = LoadingMediaState(context: context, media: media, shouldPlaying: shouldPlaying)
        context.changeState(state: state)
    }

    func pause() {
        let debug = "Already paused"
        context.debugMessage = debug
        LoggerInHouse.instance.log(message: debug, event: .warning)
    }

    func play() {
        if context.player.currentItem?.status == .readyToPlay {
            let state = BufferingState(context: context)
            context.changeState(state: state)
            state.playCommand()
        } else {
            let debug = "Please load item before playing"
            context.debugMessage = debug
            LoggerInHouse.instance.log(message: debug, event: .warning)
        }
    }

    func seek(position: Double) {
        let time = CMTime(seconds: position, preferredTimescale: context.config.preferedTimeScale)
        context.player.seek(to: time) { [context] completed in
            if completed { context.currentTime = position }
        }
    }

    func stop() {
        context.changeState(state: StoppedState(context: context))
    }
}
