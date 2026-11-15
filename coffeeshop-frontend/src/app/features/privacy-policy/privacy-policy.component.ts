import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-privacy-policy',
  standalone: true,
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="privacy-page">
      <article class="privacy-doc">
        <p class="privacy-kicker">Draft</p>
        <h1 class="privacy-title">Privacy Policy</h1>
        <p class="privacy-meta">Last updated: November 15, 2026</p>

        <p>
          This draft privacy policy describes how <strong>Find</strong> (“Find”, “we”, “us”)
          handles personal data when you use the Find web app and phone app. It is product
          documentation for transparency and store listings; it is not final legal counsel and
          may be updated as the product evolves.
        </p>

        <h2>Who we are</h2>
        <p>
          Find helps people discover cafes and events, make reservations, and—for shop
          owners—manage shops, teams, and billing. The service is operated under the Find
          product hosted at app.kafenerija.online.
        </p>

        <h2>Account and identity (Keycloak)</h2>
        <p>
          When you create an account or sign in, we process identity data such as your name,
          username, email address, password (handled by our identity provider), and account
          role (for example customer or shop owner). Authentication tokens are issued through
          <strong>Keycloak</strong> behind our API. We use this data to authenticate you,
          keep you signed in, and show your profile.
        </p>

        <h2>Reservations</h2>
        <p>
          If you request or manage a <strong>reservation</strong>, we process details such as
          party size, preferred time, related shop, and status. Shop staff who need to fulfill
          the request may see the reservation information associated with your account.
        </p>

        <h2>Billing and subscriptions</h2>
        <p>
          Shop owners who choose a paid plan provide <strong>billing</strong> and
          <strong>subscription</strong> details needed to quote and manage that plan (for
          example plan selection and account identifiers tied to the subscription). Payment
          card handling, if any, is performed by the payment process configured for Find; we
          do not intend the Find apps themselves to store full card numbers.
        </p>

        <h2>Other product data</h2>
        <p>
          Depending on how you use Find, we may also process profile preferences (such as
          favourite shops), reviews you write, shop and menu content you manage as an owner
          or employee, and operational logs needed to run and secure the service.
        </p>

        <h2>How we use data</h2>
        <p>
          We use personal data to provide Find’s features, secure accounts, communicate about
          your account or reservations when needed, and improve reliability. We do not sell
          your personal data.
        </p>

        <h2>Contact</h2>
        <p>
          Privacy questions about Find can be sent to
          <a href="mailto:privacy@kafenerija.online">privacy&#64;kafenerija.online</a>
          until a permanent contact channel is published.
        </p>

        <h2>Updates</h2>
        <p>
          We may revise this draft as Find’s features or hosting change. The “Last updated”
          date at the top will change when we publish a new version at this URL.
        </p>

        <p class="privacy-footer">
          <a routerLink="/login">Back to sign in</a>
        </p>
      </article>
    </div>
  `,
  styles: `
    .privacy-page {
      min-height: 100vh;
      background: #121212;
      padding: 2rem 1rem 3rem;
    }
    .privacy-doc {
      max-width: 40rem;
      margin: 0 auto;
      color: #e8e8e8;
      line-height: 1.6;
    }
    .privacy-kicker {
      color: #d4a574;
      font-size: 0.75rem;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      margin: 0 0 0.5rem;
    }
    .privacy-title {
      color: #fff;
      font-size: 1.75rem;
      margin: 0 0 0.25rem;
    }
    .privacy-meta {
      color: #888;
      font-size: 0.875rem;
      margin: 0 0 1.5rem;
    }
    h2 {
      color: #fff;
      font-size: 1.125rem;
      margin: 1.75rem 0 0.5rem;
    }
    p {
      margin: 0 0 0.75rem;
    }
    a {
      color: #d4a574;
    }
    .privacy-footer {
      margin-top: 2rem;
      padding-top: 1rem;
      border-top: 1px solid #2a2a3e;
    }
  `,
})
export class PrivacyPolicyComponent {}
