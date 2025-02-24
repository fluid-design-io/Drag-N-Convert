import icon from "@/app/icon.png";
import { cn } from "@workspace/ui/lib/utils";
import { ChevronRightIcon } from "lucide-react";
import Image from "next/image";
import { FC } from "react";
import { ContinousCardDesktop } from "./continous-card";

const HeroSection: FC = () => {
  return (
    <div>
      <div className='relative isolate overflow-hidden bg-linear-to-b from-primary/20'>
        <div
          aria-hidden='true'
          className='absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80'
        >
          <div
            style={{
              clipPath:
                "polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)",
            }}
            className='relative left-[calc(50%-11rem)] aspect-1155/678 w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-linear-to-tr from-[#80ffb1] to-[#af89fc] opacity-30 dark:opacity-10 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]'
          />
        </div>
        <div className='mx-auto max-w-7xl pt-24 pb-24 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40'>
          <div className='px-6 lg:px-0 lg:pt-4'>
            <div className='mx-auto max-w-2xl'>
              <div className='max-w-lg'>
                <Image src={icon} alt='icon' className='size-16' />
                <div className='mt-20 sm:mt-24 lg:mt-12'>
                  <a
                    href='https://github.com/fluid-design-io/Drag-N-Convert/releases'
                    className='inline-flex space-x-6'
                  >
                    <span className='rounded-full bg-primary/10 px-3 py-1 text-sm/6 font-semibold text-primary ring-1 ring-primary/10 ring-inset'>
                      {"What's new"}
                    </span>
                    <span className='inline-flex items-center space-x-2 text-sm/6 font-medium text-muted-foreground'>
                      <span>Concurrency v1.2.0</span>
                      <ChevronRightIcon
                        className='size-5 text-gray-400'
                        aria-hidden='true'
                      />
                    </span>
                  </a>
                </div>
                <h1 className='mt-10 text-5xl font-semibold tracking-tight text-balance sm:text-7xl'>
                  Drag <br />
                  Convert <br />
                  Done
                </h1>
                <p className='mt-6 text-lg/8 text-muted-foreground'>
                  Drag and drop images to <br /> 🔄 Convert, 📐 Resize and 📸
                  Compress
                </p>
                <div className='mt-10 flex items-center gap-x-6'>
                  <a
                    href='https://github.com/fluid-design-io/Drag-N-Convert/releases'
                    target='_blank'
                    rel='noopener noreferrer'
                    className='rounded-md bg-primary px-3.5 py-2.5 text-sm font-semibold text-primary-foreground shadow-xs focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary'
                  >
                    Download
                  </a>
                  <a
                    href='https://github.com/fluid-design-io/Drag-N-Convert'
                    target='_blank'
                    rel='noopener noreferrer'
                    className='text-sm/6 font-semibold '
                  >
                    View on GitHub <span aria-hidden='true'>→</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
          <div className='mt-20 sm:mt-24 md:mx-auto md:max-w-2xl lg:mx-0 lg:mt-0 lg:w-screen'>
            <div className='mx-auto max-w-none sm:max-w-[672px] md:mx-0 md:max-w-none overflow-hidden relative'>
              <ContinousCardDesktop className='absolute inset-0 w-full h-full' />
              <video
                src='https://raw.githubusercontent.com/fluid-design-io/Drag-N-Convert/main/assets/DNCDemo.mp4'
                autoPlay
                muted
                loop
                className={cn(
                  "object-cover",
                  "size-full sm:size-[672px]",
                  "sm:[mask-image:url(#cardMaskDesktop)]"
                )}
                style={{ aspectRatio: "1/1" }}
              />
            </div>
          </div>
        </div>
        <div className='absolute inset-x-0 bottom-0 -z-10 h-24 bg-linear-to-t from-background sm:h-32' />
      </div>
    </div>
  );
};

export default HeroSection;
