# Distribution Plan

Sardine is intended as a small tool for the author and a few trusted parents. It does not need App Store public release at the beginning.

## Recommended path: TestFlight

TestFlight is the best first distribution path for a small group.

Pros:

- No need to collect device UDIDs.
- Testers can install with an invite link or email.
- Updates are manageable.
- Suitable for a small parent group.

Cons:

- Requires Apple Developer Program membership.
- External TestFlight builds require Apple beta review.
- TestFlight builds expire, so the app must be refreshed periodically during beta.

## Alternative: Ad Hoc

Ad Hoc distribution is possible for a few fixed devices.

Pros:

- No public App Store listing.
- No TestFlight external beta review.

Cons:

- Requires collecting each iPhone UDID.
- Adding devices requires provisioning profile updates and rebuilding.
- Poor long-term maintenance experience.

Use this only if the tester group is tiny and stable.

## Not recommended: Enterprise distribution

Apple Developer Enterprise Program is for internal employee apps within an organization. It is not appropriate for sharing an app among parents or friends.

## Future public release

If Sardine becomes useful beyond a small group:

1. Add a privacy policy.
2. Add clear local-only processing language.
3. Review App Store media processing guidelines.
4. Add screenshots and onboarding.
5. Submit normal App Store release.

