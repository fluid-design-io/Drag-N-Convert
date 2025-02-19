import { Fragment } from "react";

import {
  DescriptionDetails,
  DescriptionList,
  DescriptionTerm,
} from "@workspace/ui/components/description-list";
import ServerModal from "@workspace/ui/components/server-modal";
import Link from "next/link";

const oss = [
  {
    description:
      "A lightning fast image processing and resizing library for Swift",
    name: "SwiftVips",
    href: "https://github.com/gh123man/SwiftVips",
  },
];

function FooterCredits() {
  return (
    <ServerModal
      description="the following libraries and tools were used to build this app."
      label="Credits"
      title="Thanks to..."
    >
      <DescriptionList className="px-6">
        {oss.map((item) => (
          <Fragment key={item.name}>
            <DescriptionTerm>
              <Link href={item.href} target="_blank">
                {item.name}
              </Link>
            </DescriptionTerm>
            <DescriptionDetails>{item.description}</DescriptionDetails>
          </Fragment>
        ))}
      </DescriptionList>
    </ServerModal>
  );
}

export default FooterCredits;
