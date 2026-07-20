'use client';

import React from 'react';
import { useAudio } from '../../context/AudioContext';
import { Play, Pause, X, Volume2, VolumeX, Disc } from 'lucide-react';
import Link from 'next/link';

export default function PersistentAudioPlayer() {
  const {
    currentProduct,
    isPlaying,
    progress,
    volume,
    togglePlayPause,
    seek,
    setAudioVolume,
    stopAudio,
  } = useAudio();

  if (!currentProduct) return null;

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    seek(Number(e.target.value));
  };

  const handleVolumeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setAudioVolume(Number(e.target.value));
  };

  return (
    <div className="fixed bottom-4 left-4 right-4 sm:left-1/2 sm:-translate-x-1/2 sm:w-[92%] sm:max-w-4xl z-40 animate-fade-in-up">
      <div className="bg-card/95 backdrop-blur-xl border border-primary/30 rounded-2xl p-3 sm:px-6 sm:py-3.5 shadow-2xl shadow-black/40 flex items-center justify-between gap-4 text-left">
        {/* Left: Speaker info */}
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-input-bg border border-border overflow-hidden flex-shrink-0 relative group">
            {currentProduct.images?.[0] ? (
              <img
                src={currentProduct.images[0]}
                alt={currentProduct.name}
                className="w-full h-full object-cover"
              />
            ) : (
              <Disc className="w-6 h-6 text-primary m-auto animate-spin-slow" />
            )}
            {isPlaying && (
              <div className="absolute inset-0 bg-primary/20 backdrop-blur-[1px] flex items-center justify-center">
                <Disc className="w-5 h-5 text-white animate-spin-slow" style={{ animationDuration: '4s' }} />
              </div>
            )}
          </div>

          <div className="min-w-0 flex-1">
            <span className="text-[9px] font-extrabold uppercase tracking-widest text-primary flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
              Đang Phát Âm Thử
            </span>
            <Link
              href={`/product/${currentProduct.slug}`}
              className="text-xs sm:text-sm font-bold text-foreground hover:text-primary transition-colors truncate block"
            >
              {currentProduct.name}
            </Link>
            <span className="text-[10px] text-muted-text uppercase font-semibold">{currentProduct.brand}</span>
          </div>
        </div>

        {/* Center: Controls & Scrubber */}
        <div className="flex-1 max-w-md hidden md:flex flex-col items-center gap-1 px-4">
          <div className="flex items-center gap-3">
            <button
              onClick={togglePlayPause}
              className="p-2.5 bg-primary text-white rounded-full hover:scale-105 active:scale-95 transition-all shadow-md shadow-primary/20"
              aria-label={isPlaying ? 'Pause' : 'Play'}
            >
              {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 fill-white ml-0.5" />}
            </button>
          </div>

          {/* Progress bar */}
          <div className="w-full flex items-center gap-2">
            <input
              type="range"
              min={0}
              max={100}
              value={progress}
              onChange={handleSeek}
              className="w-full h-1.5 bg-input-bg rounded-lg appearance-none cursor-pointer accent-primary"
            />
          </div>
        </div>

        {/* Right: Volume & Close */}
        <div className="flex items-center gap-3 flex-shrink-0">
          {/* Mobile Play/Pause Button */}
          <button
            onClick={togglePlayPause}
            className="md:hidden p-2 bg-primary text-white rounded-full hover:scale-105 active:scale-95 transition-all shadow-md"
          >
            {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 fill-white ml-0.5" />}
          </button>

          {/* Volume slider */}
          <div className="hidden sm:flex items-center gap-2">
            <button
              onClick={() => setAudioVolume(volume > 0 ? 0 : 0.8)}
              className="text-muted-text hover:text-foreground transition-colors"
            >
              {volume === 0 ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
            </button>
            <input
              type="range"
              min={0}
              max={1}
              step={0.05}
              value={volume}
              onChange={handleVolumeChange}
              className="w-16 h-1.5 bg-input-bg rounded-lg appearance-none cursor-pointer accent-primary"
            />
          </div>

          <button
            onClick={stopAudio}
            className="p-1.5 text-muted-text hover:text-foreground hover:bg-input-bg rounded-lg transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
