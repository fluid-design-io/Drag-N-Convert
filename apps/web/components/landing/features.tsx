import dragAndDrop from "@/public/assets/images/drag-and-drop.avif";
import featurePills from "@/public/assets/images/feature-pills.avif";
import nerdStats from "@/public/assets/images/nerd-stats.avif";
import presets from "@/public/assets/images/presets.avif";

import Image from "next/image";

export default function Features() {
  return (
    <div className='bg-gray-900 py-24 sm:py-32'>
      <div className='mx-auto max-w-2xl px-6 lg:max-w-7xl lg:px-8'>
        <h2 className='text-base/7 font-semibold text-primary'>
          Built for designers
        </h2>
        <p className='mt-2 max-w-lg text-4xl font-semibold tracking-tight text-pretty text-white sm:text-5xl'>
          Everything you need to convert images
        </p>
        <div className='mt-10 grid grid-cols-1 gap-4 sm:mt-16 lg:grid-cols-6 lg:grid-rows-2'>
          <div className='flex p-px lg:col-span-4'>
            <div className='overflow-hidden rounded-lg bg-[#202A3E] ring-1 ring-white/15 max-lg:rounded-t-[2rem] lg:rounded-tl-[2rem]'>
              <Image
                alt='Drag and Drop'
                src={dragAndDrop}
                className='h-80 object-cover object-center w-full'
                sizes='(max-width: 768px) 100vw, (max-width: 1200px) 75vw'
              />
              <div className='p-10'>
                <h3 className='text-sm/4 font-semibold text-gray-400'>
                  Simple
                </h3>
                <p className='mt-2 text-lg font-medium tracking-tight text-white'>
                  Drag and drop
                </p>
                <p className='mt-2 max-w-lg text-sm/6 text-gray-400'>
                  No more uploading, waiting, and downloading. Just drag and
                  drop them. Enjoy a simple and intuitive interface.
                </p>
              </div>
            </div>
          </div>
          <div className='flex p-px lg:col-span-2'>
            <div className='overflow-hidden rounded-lg bg-[#202A3E] ring-1 ring-white/15 lg:rounded-tr-[2rem]'>
              <Image
                alt='Feature Pills'
                src={featurePills}
                className='h-80 object-cover w-full'
                sizes='(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw'
              />
              <div className='p-10'>
                <h3 className='text-sm/4 font-semibold text-gray-400'>
                  Formats
                </h3>
                <p className='mt-2 text-lg font-medium tracking-tight text-white'>
                  Convert images to any format
                </p>
                <p className='mt-2 max-w-lg text-sm/6 text-gray-400'>
                  Convert images to modern formats like WebP, AVIF, and more.
                </p>
              </div>
            </div>
          </div>
          <div className='flex p-px lg:col-span-2'>
            <div className='overflow-hidden rounded-lg bg-[#202A3E] ring-1 ring-white/15 lg:rounded-bl-[2rem]'>
              <Image
                alt='nerd stats'
                src={nerdStats}
                className='h-80 object-cover w-full'
                sizes='(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw'
              />
              <div className='p-10'>
                <h3 className='text-sm/4 font-semibold text-gray-400'>
                  Nerd stats
                </h3>
                <p className='mt-2 text-lg font-medium tracking-tight text-white'>
                  Compression-MAX
                </p>
                <p className='mt-2 max-w-lg text-sm/6 text-gray-400'>
                  See how many bytes you can save by compressing your images.
                </p>
              </div>
            </div>
          </div>
          <div className='flex p-px lg:col-span-4'>
            <div className='overflow-hidden rounded-lg w-full bg-[#202A3E] ring-1 ring-white/15 max-lg:rounded-b-[2rem] lg:rounded-br-[2rem]'>
              <Image
                alt='presets'
                src={presets}
                className='h-80 object-cover object-left w-full'
                sizes='(max-width: 768px) 100vw, (max-width: 1200px) 75vw'
              />
              <div className='p-10'>
                <h3 className='text-sm/4 font-semibold text-gray-400'>
                  Presets
                </h3>
                <p className='mt-2 text-lg font-medium tracking-tight text-white'>
                  Save for later
                </p>
                <p className='mt-2 max-w-lg text-sm/6 text-gray-400'>
                  Converting to specific formats? Save your favorite conversions
                  for later with options to delete original images.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
