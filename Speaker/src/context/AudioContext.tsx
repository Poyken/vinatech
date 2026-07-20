'use client';

import React, { createContext, useContext, useState, useRef, useEffect } from 'react';
import { Product } from '../lib/types';

interface AudioContextType {
  currentProduct: Product | null;
  isPlaying: boolean;
  progress: number;
  duration: number;
  volume: number;
  playProductAudio: (product: Product) => void;
  togglePlayPause: () => void;
  seek: (percentage: number) => void;
  setAudioVolume: (vol: number) => void;
  stopAudio: () => void;
}

const AudioContext = createContext<AudioContextType | undefined>(undefined);

export function AudioProvider({ children }: { children: React.ReactNode }) {
  const [currentProduct, setCurrentProduct] = useState<Product | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(0.8);

  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    const audio = new Audio();
    audio.volume = volume;
    audioRef.current = audio;

    const handleTimeUpdate = () => {
      if (audio.duration) {
        setProgress((audio.currentTime / audio.duration) * 100);
      }
    };

    const handleLoadedMetadata = () => {
      setDuration(audio.duration);
    };

    const handleEnded = () => {
      setIsPlaying(false);
      setProgress(0);
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('ended', handleEnded);
      audio.pause();
    };
  }, []);

  const playProductAudio = (product: Product) => {
    if (!product.audioUrl) return;

    if (currentProduct?.id === product.id && audioRef.current) {
      togglePlayPause();
      return;
    }

    setCurrentProduct(product);
    if (audioRef.current) {
      audioRef.current.src = product.audioUrl;
      audioRef.current.play().then(() => {
        setIsPlaying(true);
      }).catch((err) => {
        console.error('Audio playback error:', err);
        setIsPlaying(false);
      });
    }
  };

  const togglePlayPause = () => {
    if (!audioRef.current || !currentProduct) return;

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current.play().then(() => {
        setIsPlaying(true);
      }).catch((err) => {
        console.error('Audio playback error:', err);
      });
    }
  };

  const seek = (percentage: number) => {
    if (audioRef.current && audioRef.current.duration) {
      const newTime = (percentage / 100) * audioRef.current.duration;
      audioRef.current.currentTime = newTime;
      setProgress(percentage);
    }
  };

  const setAudioVolume = (vol: number) => {
    setVolume(vol);
    if (audioRef.current) {
      audioRef.current.volume = vol;
    }
  };

  const stopAudio = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
    }
    setIsPlaying(false);
    setCurrentProduct(null);
    setProgress(0);
  };

  return (
    <AudioContext.Provider
      value={{
        currentProduct,
        isPlaying,
        progress,
        duration,
        volume,
        playProductAudio,
        togglePlayPause,
        seek,
        setAudioVolume,
        stopAudio,
      }}
    >
      {children}
    </AudioContext.Provider>
  );
}

export function useAudio() {
  const context = useContext(AudioContext);
  if (!context) {
    throw new Error('useAudio must be used within an AudioProvider');
  }
  return context;
}
