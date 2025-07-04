---
title: "Privacy Pass Authentication for Media over QUIC (MoQ)"
abbrev: "Privacy Pass MoQ Auth"
category: std
docname: draft-privacy-pass-moq-auth-latest
ipr: trust200902
area: Transport
workgroup: MoQ
keyword: Internet-Draft
venue:
  group: MoQ
  type: Working Group
  home: https://datatracker.ietf.org/wg/moq/
  mail: moq@ietf.org
  arch: https://mailarchive.ietf.org/arch/browse/moq/
  repo: https://github.com/moq-wg/moq-transport

stand_alone: yes
smart_quotes: no
pi: [toc, sortrefs, symrefs, docmapping]

author:
 -
    name: "Cullen Jennings"
    organization: "Cisco"
    email: "fluffy@cisco.com"
 -
    name: "Suhas Nandakumar"
    organization: "Cisco"
    email: "snandaku@cisco.com"

normative:
  RFC9576:
    title: "The Privacy Pass Architecture"
    target: https://www.rfc-editor.org/rfc/rfc9576.txt
  MoQ-TRANSPORT:
    title: "Media over QUIC Transport"
    target: https://www.ietf.org/archive/id/draft-ietf-moq-transport-12.txt
  RFC2119:
    title: "Key words for use in RFCs to Indicate Requirement Levels"
    target: https://www.rfc-editor.org/rfc/rfc2119.txt

  RFC9578:
    title: "Privacy Pass HTTP API"
    target: https://www.rfc-editor.org/rfc/rfc9578.txt

informative:
  RFC9458:
    title: "Oblivious Pseudorandom Functions (OPRFs) using Prime-Order Groups"
    target: https://www.rfc-editor.org/rfc/rfc9458.txt

--- abstract

This document specifies the use of Privacy Pass tokens for authorization in Media over QUIC (MoQ) transport protocol. It defines how Privacy Pass tokens can be integrated with MoQ's authorization framework to provide privacy-preserving authentication for subscriptions, fetches, and publications while maintaining unlinkability between clients and their media consumption patterns.

The integration addresses key privacy concerns in media streaming scenarios where traditional authentication methods can expose user viewing patterns, content preferences, and consumption habits. By leveraging Privacy Pass's cryptographic unlinkability properties, this specification enables scalable media delivery while preserving user privacy and preventing behavioral tracking across sessions.

--- middle

# Introduction

Media over QUIC (MoQ) {{MoQ-TRANSPORT}} provides a transport protocol for live and on-demand media delivery, real-time communication, and interactive content distribution over QUIC connections. The protocol supports a wide range of applications including video streaming, video conferencing, gaming, interactive broadcasts, and other latency-sensitive use cases. MoQ includes mechanisms for authorization through tokens that can be used to control access to media streams, interactive sessions, and relay operations. However, traditional authorization mechanisms can create privacy concerns in these scenarios, where user behavior patterns, communication metadata, and content preferences may be exposed to service providers and intermediaries.

Privacy Pass {{RFC9576}} provides a privacy-preserving authentication mechanism that allows clients to prove their eligibility for services without revealing identifying information. The protocol uses cryptographic techniques, specifically Oblivious Pseudorandom Functions (OPRFs), to ensure that service providers cannot link authorization tokens to specific users or correlate multiple requests from the same client. This document defines how Privacy Pass tokens can be integrated with MoQ's authorization framework to provide privacy-preserving access control for media streaming, real-time communication, and interactive content services.

The integration addresses several key use cases in modern media distribution and real-time communication:

- **Premium Content Access**: Allowing subscribers to access paid content without revealing their identity or viewing habits to content delivery networks
- **Geo-restricted Content**: Enabling location-based access control while preventing tracking of user movement patterns
- **Bandwidth-limited Services**: Providing fair usage enforcement without creating detailed per-user consumption profiles
- **Collaborative Content Distribution**: Supporting peer-to-peer and relay-based content distribution with privacy-preserving authorization
- **Video Conferencing**: Enabling privacy-preserving access control for video conferencing and collaborative communication platforms
- **Interactive Gaming**: Supporting real-time multiplayer gaming with privacy-preserving player authentication and session management
- **Live Interactive Broadcasts**: Allowing private participation in interactive live streams, polls, and audience engagement features
- **Edge Computing Services**: Providing privacy-preserving authorization for latency-sensitive applications deployed at network edges
- **Enterprise Communications**: Supporting secure and private corporate communications without exposing organizational structure or communication patterns

The key benefits of this integration include:

- **Privacy-preserving authentication**: Clients can access media content and interactive services without revealing their identity or usage patterns
- **Unlinkable authorization**: Multiple requests from the same client cannot be linked together across sessions or applications
- **Flexible attestation**: Support for various attestation mechanisms appropriate for media streaming, conferencing, and interactive scenarios
- **Relay authorization**: Privacy-preserving authorization for relay operations, content distribution, and real-time communication routing
- **Low-latency validation**: Efficient token validation suitable for real-time and interactive applications
- **Scalable deployment**: Support for both centralized and distributed authorization architectures

## Requirements Language

{::boilerplate bcp14-tagged}

# Architecture Overview

The Privacy Pass MoQ integration involves the following entities and their interactions:

- **Client**: The MoQ client requesting access to media content. The client is responsible for obtaining Privacy Pass tokens through the attestation and issuance process, and presenting these tokens when requesting MoQ operations.

- **MoQ Relay**: The MoQ relay server that forwards media content and requires authorization. The relay validates Privacy Pass tokens, enforces access policies, and forwards authorized requests to origins or other relays. Relays maintain configuration for trusted issuers but do not store client-identifying information.

- **Privacy Pass Issuer**: The entity that issues Privacy Pass tokens to clients after successful attestation. The issuer operates the token issuance protocol, manages cryptographic keys, and may implement rate limiting. The issuer cannot link issued tokens to specific clients or their subsequent usage.

- **Privacy Pass Attester**: The entity that attests to client eligibility for token issuance. The attester verifies client credentials, subscription status, or other eligibility criteria without revealing this information to the issuer. Common attestation methods include device attestation, subscriber validation, or challenge-response mechanisms.

- **Origin**: The media content provider that defines access policies and serves media content. Origins configure authorization requirements for their content and may integrate with issuers to define token metadata requirements.

## Component Interactions

The system operates through the following key interaction patterns shown in the architecture diagram:

~~~ascii
                    Privacy Pass MoQ Architecture

┌─────────────┐                               ┌─────────────┐
│   Client    │                               │Privacy Pass │
│             │◄──────────(3)────────────────│  Attester   │
└─────────────┘                               │             │
       │                                      └─────────────┘
       │                                             │
       │                                             │
       │                                      ┌─────────────┐
       │                                      │Privacy Pass │
       │                                      │   Issuer    │
       │                                      │             │
       │                                      └─────────────┘
       │                                             │
    (1)│                                          (2)│
       │                                             │
       ▼                                             ▼
┌─────────────┐           (4)            ┌─────────────┐
│   Client    │──────────────────────────►│ MoQ Relay   │
│             │                           │             │
└─────────────┘                           └─────────────┘
                                                   │
                                                   │
                                                (5)│
                                                   │
                                                   ▼
                                          ┌─────────────┐
                                          │   Origin    │
                                          │             │
                                          └─────────────┘
                                                   │
                                                   │
                                                (6)│
                                                   │
                                                   ▼
                                          ┌─────────────┐
                                          │   Policy    │
                                          │  Manager    │
                                          │             │
                                          └─────────────┘

Flow Legend:
(1) Token Provisioning: Client → Attester → Issuer → Client
(2) Authorization: Client → Relay → Origin → Relay → Client
(3) Policy Coordination: Origin → Relay → Issuer
~~~

1. **Token Provisioning**: Clients periodically obtain tokens from issuers through the attestation process, typically before accessing media content.

2. **Authorization Flow**: When clients request MoQ operations, they present tokens to relays, which validate tokens and enforce access policies.

3. **Content Delivery**: Authorized clients receive media content through the standard MoQ transport mechanisms.

4. **Policy Management**: Origins and relays coordinate on access policies, while issuers and attesters manage token issuance policies.

## Alternate Architecture: Separated Issuer and Relay

In many deployments, the MoQ relay and Privacy Pass issuer are operated by different entities to enhance privacy and security separation. This alternate architecture provides stronger privacy guarantees by ensuring that no single entity can both issue tokens and observe their usage patterns.

~~~ascii
                 Separated Issuer and Relay Architecture

┌─────────────┐                               ┌─────────────┐
│   Client    │                               │Privacy Pass │
│             │◄──────────(3)────────────────│  Attester   │
└─────────────┘                               │ (3rd Party) │
       │                                      └─────────────┘
    (1)│                                             │
       │                                             │
       ▼                                      ┌─────────────┐
┌─────────────┐                               │Privacy Pass │
│   Client    │                               │   Issuer    │
│             │                               │ (Auth Svc)  │
└─────────────┘                               └─────────────┘
       │                                             │
    (4)│                                          (2)│
       │                                             │
       ▼                                             ▼
┌─────────────┐       (5)        ┌─────────────┐
│ MoQ Relay   │──────────────────────────►│   Token     │
│ (CDN/ISP)   │                           │ Validator   │
└─────────────┘                           │ (Separate)  │
       │                                      └─────────────┘
    (8)│                                             │
       │                                          (6)│
       ▼                                             │
┌─────────────┐                                      │
│   Origin    │                               ┌─────────────┐
│ (Publisher) │                               │Privacy Pass │
└─────────────┘                               │   Issuer    │
       │                                      │ (Auth Svc)  │
    (9)│                                      └─────────────┘
       │                                             │
       │                                         (12)│
       │                                             │
       ▼                                             ▼
┌─────────────┐                                      │
│   Client    │                               (11)│
│             │                                      │
└─────────────┘                                      │

Benefits:
• Enhanced privacy: Issuer cannot observe content consumption patterns
• Reduced correlation: Relay cannot link tokens to user identities
• Regulatory compliance: Separation of token issuance and content delivery
• Scalability: Independent scaling of issuer and relay infrastructure

Flow Legend:
(1) Token Provisioning: Client → Attester → Issuer → Client
(2) Authorization: Client → Relay → Validator → Relay → Client
(3) Content Delivery: Relay → Origin → Relay → Client
(4) Policy Coordination: Origin → Validator → Issuer
~~~

### Key Differences from Integrated Architecture

1. **Token Validation Service**: A separate token validation service validates tokens on behalf of the relay, without revealing token contents to the relay operator.

2. **Privacy Pass Issuer Independence**: The issuer operates independently of content delivery infrastructure, preventing correlation between token issuance and content consumption.

3. **Enhanced Unlinkability**: Even if the relay is compromised, it cannot link tokens back to specific users or issuance events.

4. **Regulatory Separation**: Supports regulatory frameworks requiring separation between authentication providers and content delivery networks.

### Validation Flow in Separated Architecture

~~~ascii
                        Separated Issuer Validation Flow

   Client      MoQ Relay    Token Validator   Privacy Pass Issuer   Origin
     |             |              |                     |             |
     |             |              |                     |             |
     |  (1) MoQ Request + Token   |                     |             |
     |------------>|              |                     |             |
     |             |              |                     |             |
     |             |  (2) Validate Token (encrypted)   |             |
     |             |------------->|                     |             |
     |             |              |                     |             |
     |             |              |  (3) Verify Signature             |
     |             |              |-------------------->|             |
     |             |              |                     |             |
     |             |              |  (4) Validation Result            |
     |             |              |<--------------------|             |
     |             |              |                     |             |
     |             |  (5) Authorization Decision       |             |
     |             |<-------------|                     |             |
     |             |              |                     |             |
     |             |  (6) Content Request (if authorized)            |
     |             |---------------------------------------------->|
     |             |              |                     |             |
     |             |  (7) Content Response                         |
     |             |<----------------------------------------------|             |
     |             |              |                     |             |
     |  (8) MoQ Response          |                     |             |
     |<------------|              |                     |             |
     |             |              |                     |             |

Notes:
• Step 2: Token sent over secure channel
• Step 3: Cryptographic verification only
• Step 5: Binary allow/deny only
• Step 6: Only if authorized
~~~

### Deployment Considerations for Separated Architecture

- **Network Latency**: Additional hop to token validator may increase authorization latency
- **High Availability**: Token validator becomes critical component requiring redundancy
- **Trust Relationships**: Requires establishing trust between relay operator and validation service
- **Cost Distribution**: Validation costs separated from content delivery costs
- **Compliance**: Easier to meet regulatory requirements for data separation

## Trust Model

The architecture assumes the following trust relationships:

- **Clients trust issuers** to provide valid tokens and not collude with relays to break unlinkability
- **Relays trust issuers** to properly validate client eligibility before issuing tokens
- **Issuers trust attesters** to accurately verify client eligibility
- **Origins trust relays** to enforce access policies correctly
- **No entity trusts any other** to preserve client privacy beyond their specific role requirements

## Token Types for MoQ Authorization

This specification defines specific Privacy Pass token types for MoQ operations, each designed for different authorization scenarios:

- **MoQ-Subscribe Token**: Used for authorizing subscription requests to live or on-demand media streams. These tokens may include metadata specifying track namespace restrictions, quality level limits, and subscription duration.

- **MoQ-Fetch Token**: Used for authorizing fetch requests for specific media objects or catalog information. These tokens typically have shorter validity periods and may include object-specific access controls.

- **MoQ-Publish Token**: Used for authorizing publication requests from content producers. These tokens may include metadata specifying allowed track namespaces, maximum bitrate limits, and content classification restrictions.

- **MoQ-Relay Token**: Used for authorizing relay operations when clients or servers need to establish relay connections. These tokens may specify relay capacity limits, allowed origin servers, and geographical restrictions.

- **MoQ-Conference Token**: Used for authorizing participation in video conferencing and collaborative communication sessions. These tokens may include metadata specifying conference room access, participant roles, and session duration limits.

- **MoQ-Interactive Token**: Used for authorizing interactive and real-time communication features such as gaming, live polls, and audience participation. These tokens may include metadata specifying interaction types, rate limits, and quality-of-service requirements.

### Token Scope and Granularity

Tokens can be issued with varying levels of granularity:

- **Broad Scope**: Single token authorizing multiple operations across different track namespaces
- **Medium Scope**: Token authorizing specific operation types (e.g., all subscribe operations) within defined limits
- **Narrow Scope**: Token authorizing specific operations on particular tracks or objects

The choice of token scope involves a privacy-utility tradeoff: broader tokens provide better privacy by reducing the frequency of token requests, while narrower tokens provide finer-grained access control and limit the impact of token compromise.

# Privacy Pass Token Integration

This section describes how Privacy Pass tokens are integrated into the MoQ transport protocol to provide privacy-preserving authorization for various media and communication use cases. The integration leverages MoQ's existing authorization framework while adding the cryptographic privacy guarantees provided by Privacy Pass.

## Token Registration

Privacy Pass tokens are integrated into MoQ using the existing AUTHORIZATION TOKEN parameter mechanism defined in the MoQ Transport specification. The integration follows a structured approach where tokens are embedded within MoQ control messages to authorize specific operations before they are performed.

The token type field in the AUTHORIZATION TOKEN parameter MUST be set to indicate the Privacy Pass token type being used. This allows relays to determine the appropriate validation procedure and understand the authorization scope of the presented token. The integration supports both privately verifiable and publicly verifiable Privacy Pass tokens, with the choice depending on the deployment architecture and privacy requirements.

The token registration process involves several key steps:

1. **Token Type Identification**: Each token includes a type identifier that specifies the MoQ operation it authorizes
2. **Metadata Extraction**: Relays extract public metadata from tokens to understand authorization scope
3. **Validation Context**: Tokens are validated within the context of the specific MoQ operation being requested
4. **Policy Enforcement**: Token metadata is used to enforce fine-grained access control policies

### Token Type Registry

This document registers the following token types for use with MoQ:

- Token Type 0x0001: MoQ-Subscribe Privacy Pass Token
- Token Type 0x0002: MoQ-Fetch Privacy Pass Token  
- Token Type 0x0003: MoQ-Publish Privacy Pass Token
- Token Type 0x0004: MoQ-Relay Privacy Pass Token
- Token Type 0x0005: MoQ-Conference Privacy Pass Token
- Token Type 0x0006: MoQ-Interactive Privacy Pass Token

## Token Structure

Privacy Pass tokens used in MoQ MUST follow the structure defined in {{RFC9576}} and use the issuance protocols specified in {{RFC9578}} with MoQ-specific adaptations. The token structure is designed to balance privacy protection with the functional requirements of media transport authorization.

The basic token structure consists of several key components:

- **Token Header**: Contains version information, token type, and issuer identification
- **Public Metadata**: Includes authorization scope, validity period, and operational constraints
- **Private Token Value**: A cryptographically secure, unlinkable identifier generated through the Privacy Pass issuance protocol
- **Cryptographic Proof**: Either a VOPRF proof for privately verifiable tokens or a blind signature for publicly verifiable tokens

The token structure is optimized for MoQ's performance requirements while maintaining the privacy guarantees of the Privacy Pass protocol. Special consideration is given to real-time applications where token validation must be performed with minimal latency impact on media delivery.

For interactive applications such as video conferencing and gaming, tokens may include additional metadata to support quality-of-service requirements and session management. This metadata is included in the public portion of the token and is visible to relays for policy enforcement purposes.

### Token Metadata

Privacy Pass tokens MAY include public metadata to convey authorization scope. The metadata is included in the token structure and is visible to relays during validation:

- **Track Namespace**: The namespace of tracks the token authorizes, using glob patterns for flexibility
  - Example: "sports.example.com/live/*" (all live sports content)
  - Example: "vod.example.com/movies/action/*" (specific genre)
  - Example: "user-content.example.com/stream/user123/*" (specific user's content)

- **Operation Type**: The type of MoQ operation (subscribe, fetch, publish, relay)
  - Value: 0x01 (Subscribe), 0x02 (Fetch), 0x03 (Publish), 0x04 (Relay)

- **Validity Period**: The time period for which the token is valid
  - Format: Unix timestamp (seconds since epoch)
  - Example: issued_at=1640995200, expires_at=1640998800 (1 hour validity)

- **Rate Limits**: Maximum request rate or bandwidth limits
  - Format: {"max_requests_per_second": 10, "max_bandwidth_mbps": 50}
  - Example: {"max_subscriptions": 5, "max_concurrent_fetches": 3}

- **Quality Restrictions**: Maximum quality levels or codec restrictions
  - Format: {"max_resolution": "1080p", "allowed_codecs": ["h264", "av1"]}
  - Example: {"max_bitrate_kbps": 8000, "hdr_allowed": false}

- **Geographic Restrictions**: Location-based access control
  - Format: {"allowed_regions": ["US", "CA", "MX"]}
  - Example: {"blocked_regions": ["CN", "RU"]}

- **Latency Requirements**: Quality-of-service parameters for real-time applications
  - Format: {"max_latency_ms": 100, "priority": "high", "jitter_tolerance_ms": 20}
  - Example: {"interactive_mode": true, "max_e2e_latency_ms": 150}

- **Session Parameters**: Configuration for interactive and collaborative sessions
  - Format: {"max_participants": 50, "session_type": "conference", "recording_allowed": false}
  - Example: {"moderator_role": true, "screen_sharing_allowed": true}

### Token Structure Examples

#### Example 1: Live Sports Subscription Token

~~~json
{
  "token_type": "0x0001",
  "description": "MoQ-Subscribe Privacy Pass",
  "issuer_key_id": "0x0001",
  "token_metadata": {
    "operation": "subscribe",
    "track_namespace": "sports.example.com/live/*",
    "issued_at": 1640995200,
    "expires_at": 1640998800,
    "max_quality": "1080p",
    "max_bitrate_kbps": 8000,
    "allowed_regions": ["US", "CA"]
  },
  "token_value": "[32-byte opaque token]",
  "proof": "[VOPRF proof or blind signature]"
}
~~~

#### Example 2: Video-on-Demand Fetch Token

~~~json
{
  "token_type": "0x0002",
  "description": "MoQ-Fetch Privacy Pass",
  "issuer_key_id": "0x0002",
  "token_metadata": {
    "operation": "fetch",
    "object_pattern": "vod.example.com/movies/*/segments/*",
    "issued_at": 1640995200,
    "expires_at": 1640999100,
    "max_concurrent_fetches": 5,
    "max_bandwidth_mbps": 25,
    "content_rating": "PG-13"
  },
  "token_value": "[32-byte opaque token]",
  "proof": "[VOPRF proof or blind signature]"
}
~~~

#### Example 3: Content Publication Token

~~~json
{
  "token_type": "0x0003",
  "description": "MoQ-Publish Privacy Pass",
  "issuer_key_id": "0x0003",
  "token_metadata": {
    "operation": "publish",
    "track_namespace": "user-content.example.com/stream/user456/*",
    "issued_at": 1640995200,
    "expires_at": 1641009600,
    "max_bitrate_kbps": 5000,
    "max_duration_seconds": 14400,
    "content_rating": "General",
    "moderation_required": true
  },
  "token_value": "[32-byte opaque token]",
  "proof": "[VOPRF proof or blind signature]"
}
~~~

#### Example 4: Video Conference Token

~~~json
{
  "token_type": "0x0005",
  "description": "MoQ-Conference Privacy Pass",
  "issuer_key_id": "0x0004",
  "token_metadata": {
    "operation": "conference",
    "room_namespace": "conf.example.com/room/meeting123",
    "issued_at": 1640995200,
    "expires_at": 1641002400,
    "max_participants": 25,
    "moderator_role": false,
    "screen_sharing_allowed": true,
    "recording_allowed": false,
    "max_latency_ms": 100,
    "interactive_mode": true
  },
  "token_value": "[32-byte opaque token]",
  "proof": "[VOPRF proof or blind signature]"
}
~~~

#### Example 5: Interactive Gaming Token

~~~json
{
  "token_type": "0x0006",
  "description": "MoQ-Interactive Privacy Pass",
  "issuer_key_id": "0x0005",
  "token_metadata": {
    "operation": "interactive",
    "game_namespace": "game.example.com/session/multiplayer/*",
    "issued_at": 1640995200,
    "expires_at": 1640999400,
    "max_latency_ms": 50,
    "priority": "high",
    "jitter_tolerance_ms": 10,
    "max_players": 8,
    "game_mode": "realtime",
    "anti_cheat_required": true
  },
  "token_value": "[32-byte opaque token]",
  "proof": "[VOPRF proof or blind signature]"
}
~~~

### Token Challenge and Redemption

The token challenge and redemption process follows the Privacy Pass architecture with MoQ-specific adaptations:

~~~ascii
                    Token Registration and Validation Flow

   Client      Attester      Issuer       Relay        Origin
     |            |            |            |            |
     |            |            |            |            |
     |  (1) Request Service   |            |            |
     |----------->|            |            |            |
     |            |            |            |            |
     |            |            |  (2) Challenge        |
     |<------------------------------------|            |
     |            |            |            |            |
     |  (3) Attestation       |            |            |
     |----------->|            |            |            |
     |            |            |            |            |
     |            |  (4) Forward Attestation            |
     |            |----------->|            |            |
     |            |            |            |            |
     |            |  (5) Token |            |            |
     |<-----------------------|            |            |
     |            |            |            |            |
     |            |            |  (6) MoQ Request + Token
     |------------------------------------>|            |
     |            |            |            |            |
     |            |            |  (7) Validate Token   |
     |            |            |<-----------|            |
     |            |            |            |            |
     |            |            |  (8) Policy Check     |
     |            |            |----------->|            |
     |            |            |            |            |
     |            |            |            |  (9) Request
     |            |            |            |----------->|
     |            |            |            |            |
     |            |            |            |  (10) Content
     |            |            |            |<-----------|
     |            |            |            |            |
     |            |            |  (11) Response        |
     |<------------------------------------|            |
     |            |            |            |            |
~~~

1. **Challenge**: MoQ relay sends a token challenge when authorization is required
2. **Attestation**: Client proves eligibility through configured attestation mechanism  
3. **Issuance**: Client receives Privacy Pass token from issuer using HTTP API {{RFC9578}}
4. **Redemption**: Client presents token in MoQ AUTHORIZATION TOKEN parameter

### Supported Token Types

This specification supports both issuance protocol variants defined in {{RFC9578}}:

- **Privately Verifiable Tokens**: Using VOPRF with P-384 and SHA-384
  - **Use Case**: Scenarios where only the issuer needs to verify tokens
  - **Advantages**: Stronger privacy guarantees, smaller token size
  - **Deployment**: Single-issuer deployments, centralized validation
  - **Token Size**: ~96 bytes (32-byte token + 64-byte VOPRF proof)

- **Publicly Verifiable Tokens**: Using Blind RSA with 2048-bit keys
  - **Use Case**: Scenarios where multiple parties need to verify tokens
  - **Advantages**: Distributed validation, key rotation flexibility
  - **Deployment**: Multi-issuer deployments, federated validation
  - **Token Size**: ~256 bytes (32-byte token + 256-byte RSA signature)

The choice of token type depends on the deployment model and privacy requirements of the MoQ service:

#### Deployment Considerations

- **Single CDN**: Privately verifiable tokens provide optimal privacy and performance
- **Multi-CDN Federation**: Publicly verifiable tokens enable cross-CDN validation
- **Edge Computing**: Privately verifiable tokens reduce computational overhead
- **Regulatory Compliance**: Publicly verifiable tokens may be required for auditability

#### Performance Characteristics

- **Issuance Latency**: VOPRF issuance typically faster than Blind RSA
- **Validation Latency**: Both types have similar validation performance
- **Network Overhead**: Privately verifiable tokens have lower bandwidth requirements
- **Storage Requirements**: Privately verifiable tokens require less storage per token

# Authorization Flows

This section describes the detailed authorization flows for different MoQ operations using Privacy Pass tokens. The flows are designed to provide privacy-preserving authorization while maintaining the performance characteristics required for media transport and real-time communication.

The authorization flows support various MoQ operations including media subscription, content fetching, publication, relay operations, video conferencing, and interactive gaming. Each flow is tailored to the specific requirements of the operation while maintaining consistent privacy guarantees through the use of Privacy Pass tokens.

The flows are structured to minimize latency impact on media delivery, particularly for real-time applications where authorization delays can significantly affect user experience. To achieve this, the design incorporates token caching, pre-validation, and optimized cryptographic operations.

## Subscription Authorization

When a client wants to subscribe to a track, the following detailed authorization flow occurs. This flow is optimized for media streaming scenarios where clients need to receive live or on-demand media content while maintaining privacy about their viewing patterns and preferences.

The subscription authorization flow supports various media types including video streams, audio content, and interactive media. It includes provisions for different subscription models such as pay-per-view, subscription-based access, and geographic restrictions while preserving user privacy through unlinkable authorization tokens.

### Basic Subscription Flow

1. **Client Request**: Client sends SUBSCRIBE message with Privacy Pass token in the AUTHORIZATION TOKEN parameter
2. **Token Validation**: Relay validates the token signature, expiration, and metadata
3. **Authorization Check**: Relay verifies that the token authorizes subscription to the requested track namespace
4. **Response**: If authorized, relay processes the subscription and returns SUBSCRIBE_OK; otherwise returns SUBSCRIBE_ERROR

~~~ascii
                       Basic Subscription Flow

     Client            Relay             Issuer
       |                 |                 |
       |                 |                 |
       |  (1) SUBSCRIBE with Privacy Pass Token
       |---------------->|                 |
       |                 |                 |
       |                 |  (2) Token Verification
       |                 |---------------->|
       |                 |                 |
       |                 |  (3) Validation Result
       |                 |<----------------|
       |                 |                 |
       |  (4) SUBSCRIBE_OK/ERROR           |
       |<----------------|                 |
       |                 |                 |
~~~

### Example: Live Sports Stream Subscription

Consider a client wanting to subscribe to a live sports stream with track namespace "sports.example.com/live/soccer/match123":

1. **Token Presentation**: Client includes a MoQ-Subscribe token with metadata:

   ```
   Token Type: 0x0001 (MoQ-Subscribe)
   Track Namespace: "sports.example.com/live/*"
   Validity: 3600 seconds
   Quality Limit: "1080p"
   ```

2. **Validation**: Relay checks that:

   - Token signature is valid and from trusted issuer
   - Current time is within token validity period
   - Requested track "sports.example.com/live/soccer/match123" matches the allowed namespace pattern
   - Client hasn't exceeded quality limits

3. **Authorization Decision**: If all checks pass, relay forwards the subscription to the origin and begins forwarding media data to the client.

### Error Scenarios

Common error scenarios include:

- **Invalid Token**: Token signature verification fails
- **Expired Token**: Current time exceeds token validity period
- **Scope Mismatch**: Requested track namespace not authorized by token
- **Rate Limit Exceeded**: Client has exceeded token-specified rate limits
- **Replay Attack**: Token has been previously used (for single-use tokens)

## Fetch Authorization

For fetch operations, the authorization flow is similar but optimized for object-specific access:

### Basic Fetch Flow

1. **Client Request**: Client sends FETCH message with Privacy Pass token specifying the object to retrieve
2. **Token Validation**: Relay validates token and checks object-specific authorization
3. **Object Access**: If authorized, relay retrieves and returns the requested object
4. **Response**: Relay returns FETCH_OK with object data or FETCH_ERROR if unauthorized

### Example: Video-on-Demand Content Fetch

Consider a client fetching a specific video segment:

1. **Token Presentation**: Client includes a MoQ-Fetch token with metadata:

   ```
   Token Type: 0x0002 (MoQ-Fetch)
   Object Pattern: "vod.example.com/movies/*/segments/*"
   Validity: 1800 seconds
   Bandwidth Limit: 10 Mbps
   ```

2. **Object Authorization**: Relay verifies that the requested object "vod.example.com/movies/action/segment001" matches the authorized pattern and the client hasn't exceeded bandwidth limits.

3. **Content Delivery**: If authorized, relay retrieves the segment from the origin and streams it to the client.

### Catalog Access Example

For catalog or metadata fetches:

1. **Catalog Token**: Client presents token authorizing access to content catalogs:

   ```
   Token Type: 0x0002 (MoQ-Fetch)
   Object Pattern: "catalog.example.com/*/metadata"
   Validity: 7200 seconds
   ```

2. **Metadata Retrieval**: Relay authorizes and returns catalog information, allowing the client to discover available content without revealing viewing preferences.

## Publication Authorization

For publication operations, the authorization flow includes additional considerations for content policy enforcement:

### Basic Publication Flow

1. **Announcement**: Client sends ANNOUNCE message with Privacy Pass token to declare intent to publish
2. **Token Validation**: Relay validates token and checks publication authorization scope
3. **Policy Enforcement**: Relay verifies that the publication request complies with content policies
4. **Publication Setup**: If authorized, relay allows the client to begin publishing media data

### Example: Live Streaming Publication

Consider a content creator starting a live stream:

1. **Token Presentation**: Client includes a MoQ-Publish token with metadata:

   ```
   Token Type: 0x0003 (MoQ-Publish)
   Track Namespace: "user-content.example.com/stream/user456/*"
   Validity: 14400 seconds (4 hours)
   Max Bitrate: 5 Mbps
   Content Rating: "General"
   ```

2. **Publication Authorization**: Relay verifies:
   - Token authorizes publication to the requested namespace
   - Client has valid publishing rights for the user account
   - Content rating matches platform policies
   - Bitrate limits are within allowed ranges

3. **Stream Setup**: If authorized, relay begins accepting media data from the client and makes it available to subscribers.

### Content Moderation Integration

The publication flow can integrate with content moderation systems:

1. **Pre-publication Checks**: Relay may require additional attestation for content classification
2. **Real-time Monitoring**: Tokens may include metadata enabling automated content policy enforcement
3. **Revocation Handling**: Relay supports token revocation for policy violations

### Multi-relay Publication

For distributed content delivery:

1. **Origin Publication**: Client publishes to origin relay with MoQ-Publish token
2. **Relay Authorization**: Downstream relays use MoQ-Relay tokens to fetch and redistribute content
3. **Authorization Propagation**: Token metadata flows through the relay network to maintain consistent access control

## Conference Authorization

For video conferencing and collaborative sessions, the authorization flow includes session management and participant coordination:

### Basic Conference Flow

~~~ascii
                          Basic Conference Flow

 Participant A    Relay    Conference Server    Participant B
     |             |              |                 |
     |             |              |                 |
     |  (1) JOIN + Token         |                 |
     |------------>|              |                 |
     |             |              |                 |
     |             |  (2) VALIDATE Token           |
     |             |------------->|                 |
     |             |              |                 |
     |             |  (3) PARTICIPANT_LIST         |
     |             |<-------------|                 |
     |             |              |                 |
     |  (4) JOIN_OK              |                 |
     |<------------|              |                 |
     |             |              |                 |
     |             |              |  (5) JOIN + Token
     |             |<-------------------------------|              
     |             |              |                 |
     |             |  (6) VALIDATE Token           |
     |             |------------->|                 |
     |             |              |                 |
     |             |  (7) PARTICIPANT_LIST         |
     |             |<-------------|                 |
     |             |              |                 |
     |             |              |  (8) JOIN_OK   |
     |             |------------------------------>|
     |             |              |                 |
     |  (9) NOTIFY New User      |                 |
     |<------------|              |                 |
     |             |              |                 |
     |  (10) MEDIA (via Relay)                     |
     |-------------------------------------------->|
     |             |              |                 |
     |  (11) MEDIA (via Relay)                     |
     |<--------------------------------------------|
     |             |              |                 |
~~~

### Conference Room Authorization

Consider a video conference with multiple participants:

1. **Token Presentation**: Each participant presents a MoQ-Conference token with metadata:
   ~~~json
   {
     "token_type": "0x0005",
     "token_metadata": {
       "operation": "conference",
       "room_namespace": "conf.example.com/room/meeting456",
       "max_participants": 50,
       "moderator_role": false,
       "max_latency_ms": 100,
       "session_duration_seconds": 3600
     }
   }
   ~~~

2. **Session Validation**: Relay checks that:
   - Token authorizes access to the specific conference room
   - Participant count doesn't exceed room limits
   - Session hasn't exceeded duration limits
   - Participant role matches authorization level

3. **Media Flow Setup**: If authorized, relay establishes bidirectional media flows between participants while maintaining privacy through unlinkable authorization.

## Interactive Gaming Authorization

For real-time gaming scenarios, the authorization flow includes latency-sensitive validation and session state management:

### Gaming Session Flow

~~~ascii
                            Gaming Session Flow

   Player A      Game Relay      Game Server      Player B
     |             |                 |              |
     |             |                 |              |
     |  (1) CONNECT + Token         |              |
     |------------>|                 |              |
     |             |                 |              |
     |             |  (2) VALIDATE Token           |
     |             |---------------->|              |
     |             |                 |              |
     |             |  (3) GAME_STATE |              |
     |             |<----------------|              |
     |             |                 |              |
     |  (4) CONNECT_OK              |              |
     |<------------|                 |              |
     |             |                 |              |
     |             |                 |  (5) CONNECT + Token
     |             |<------------------------------|              
     |             |                 |              |
     |             |  (6) VALIDATE Token           |
     |             |---------------->|              |
     |             |                 |              |
     |             |  (7) GAME_STATE |              |
     |             |<----------------|              |
     |             |                 |              |
     |             |                 |  (8) CONNECT_OK
     |             |------------------------------>|
     |             |                 |              |
     |  (9) GAME_EVENT (low latency via Game Relay)   |
     |---------------------------------------------->|
     |             |                 |              |
     |  (10) GAME_EVENT (low latency via Game Relay)  |
     |<----------------------------------------------|
     |             |                 |              |
~~~

### Gaming Token Validation

Gaming tokens require special handling for latency-sensitive operations:

1. **Token Presentation**: Players present MoQ-Interactive tokens with gaming-specific metadata:
   ~~~json
   {
     "token_type": "0x0006",
     "token_metadata": {
       "operation": "interactive",
       "game_namespace": "game.example.com/session/fps123",
       "max_latency_ms": 50,
       "priority": "high",
       "anti_cheat_required": true,
       "max_players": 16
     }
   }
   ~~~

2. **Real-time Validation**: Relay performs rapid token validation with:
   - Cached validation results to minimize latency
   - Optimized cryptographic operations
   - Precomputed authorization decisions

3. **Session Management**: Gaming sessions require:
   - Continuous authorization for real-time events
   - Fraud prevention through token metadata
   - Dynamic session scaling based on player count

# Privacy Considerations

This section addresses the privacy implications of using Privacy Pass tokens in MoQ environments, with particular attention to the unique challenges posed by media streaming, real-time communication, and interactive applications. The privacy protections must be maintained across various usage patterns including one-time media consumption, ongoing communication sessions, and interactive gaming scenarios.

The privacy considerations are organized around three core principles: unlinkability of client requests, minimization of metadata exposure, and protection against side-channel attacks. These principles are applied consistently across all MoQ operations while accounting for the specific requirements of different media and communication use cases.

## Unlinkability

Maintaining unlinkability between client requests is fundamental to the privacy guarantees provided by Privacy Pass in MoQ deployments. This property ensures that service providers cannot correlate multiple requests from the same client, even when those requests are made across different sessions or for different content.

To maintain unlinkability between client requests:

- Tokens MUST be single-use for each MoQ operation to prevent correlation across requests
- Clients SHOULD obtain fresh tokens for each session to avoid long-term tracking
- Relays MUST NOT log or store information that could link tokens to clients or sessions
- Token issuance timing SHOULD be randomized to prevent correlation based on temporal patterns

For interactive applications such as video conferencing and gaming, special considerations apply:

- Conference tokens SHOULD be issued per-session rather than per-participant to prevent correlation
- Gaming tokens SHOULD use session-based scoping to prevent player tracking across game sessions
- Interactive tokens SHOULD include sufficient entropy to prevent fingerprinting based on usage patterns

## Metadata Minimization

Token metadata exposure represents a potential privacy risk, as metadata is visible to relays during authorization. The principle of metadata minimization requires that only the minimum necessary information be included in token metadata to achieve the required authorization functionality.

- Token metadata SHOULD be minimized to only include necessary authorization information
- Clients SHOULD use different tokens for different track namespaces when possible to limit scope exposure
- Issuers SHOULD implement rate limiting to prevent token stockpiling and bulk correlation
- Metadata encoding SHOULD be standardized to prevent fingerprinting based on formatting differences

For real-time applications, metadata minimization faces additional challenges:

- Quality-of-service parameters may reveal user preferences or device capabilities
- Session management metadata may expose usage patterns or group affiliations
- Interactive features may require metadata that could enable behavioral tracking

## Side-Channel Protection

Side-channel attacks represent a significant threat to privacy in token-based authorization systems. These attacks can exploit timing variations, network traffic patterns, or computational differences to infer information about tokens or their bearers.

- Implementations MUST implement timing attack protections during token validation
- Token validation SHOULD have consistent timing regardless of validation result
- Network-level protections SHOULD be implemented to prevent traffic analysis
- Cryptographic operations SHOULD use constant-time algorithms to prevent timing leakage

Additional side-channel protections for interactive applications:

- Real-time validation SHOULD use cached results to prevent timing correlation
- Interactive session patterns SHOULD be obfuscated to prevent behavioral fingerprinting
- Network traffic padding SHOULD be considered for high-sensitivity applications

## Interactive Application Privacy

Interactive applications such as video conferencing and gaming present unique privacy challenges that require additional consideration:

### Communication Metadata Protection

- Participant lists and room membership SHOULD be protected from unauthorized disclosure
- Communication patterns (who talks to whom, when, and for how long) SHOULD be minimized in logs
- Session metadata SHOULD be limited to operational requirements only

### Real-time Behavioral Privacy

- Gaming actions and communication patterns SHOULD NOT be linkable across sessions
- Interactive features SHOULD be designed to minimize behavioral fingerprinting
- Real-time metrics SHOULD be aggregated to prevent individual pattern recognition

### Session Privacy

- Multi-party sessions SHOULD use techniques to prevent correlation of participants
- Session duration and participation patterns SHOULD be protected from analysis
- Cross-session correlation SHOULD be prevented through proper token scope management

# Security Considerations

This section addresses the security implications of using Privacy Pass tokens in MoQ environments, covering both the cryptographic security of the token system and the operational security of deployed systems. The security considerations encompass various threat models including malicious clients, compromised relays, and network-level attacks.

The security framework is designed to address the unique challenges of media transport and real-time communication, where high availability and low latency requirements must be balanced against security protections. Special attention is given to the security implications of interactive applications where real-time constraints may limit the feasibility of certain security measures.

## Token Validation

Proper token validation is critical to the security of the entire system. Relays MUST properly validate Privacy Pass tokens according to {{RFC9576}} and {{RFC9578}}, with additional considerations for MoQ-specific requirements and performance constraints.

The token validation process includes multiple layers of verification:

- **Cryptographic Verification**: Verify token signature using the appropriate public key for the issuer
- **Temporal Validation**: Check token expiration and validity period to prevent use of expired tokens
- **Scope Validation**: Validate token metadata matches the requested operation and authorization scope
- **Replay Protection**: Ensure token has not been previously redeemed (replay protection)
- **Issuer Verification**: Verify the token key ID matches a trusted issuer in the relay's configuration
- **Protocol-Specific Validation**: For privately verifiable tokens, verify the VOPRF proof; for publicly verifiable tokens, verify the blind RSA signature

For real-time applications, validation must be optimized for performance:

- **Cached Validation**: Use cached validation results for recently validated tokens to reduce latency
- **Parallel Validation**: Perform multiple validation steps in parallel where possible
- **Optimized Cryptography**: Use hardware acceleration for cryptographic operations when available
- **Precomputed Values**: Precompute expensive cryptographic operations during system initialization

## Issuer Trust

- Relays MUST maintain a trusted set of Privacy Pass issuers
- Issuer key rotation procedures MUST be implemented
- Revocation mechanisms SHOULD be supported for compromised issuers

## Rate Limiting

- Issuers SHOULD implement rate limiting to prevent abuse
- Relays SHOULD implement per-client rate limiting based on token metadata
- Distributed rate limiting mechanisms SHOULD be considered for multi-relay deployments

### Rate Limiting Implementation

- **Token Bucket Algorithm**: Recommended for smooth rate limiting
- **Sliding Window**: Alternative approach for burst handling
- **Distributed Counting**: Coordination across multiple relay instances
- **Metadata-Based Limits**: Use token metadata to enforce different limits per client class

## Error Handling

### Token Validation Errors

Relays MUST handle token validation errors gracefully and provide appropriate error responses:

- **Invalid Signature**: Return SUBSCRIBE_ERROR, FETCH_ERROR, or ANNOUNCE_ERROR with error code 0x01
- **Expired Token**: Return error with code 0x02 and include current server time
- **Scope Mismatch**: Return error with code 0x03 and specify required authorization scope
- **Rate Limit Exceeded**: Return error with code 0x04 and include retry-after information
- **Replayed Token**: Return error with code 0x05 to prevent replay attacks

### Issuer Availability

When issuer services are unavailable:

- **Graceful Degradation**: Accept cached validation results for recently validated tokens
- **Fallback Mechanisms**: Implement backup issuer services or manual override capabilities
- **Client Retry Logic**: Clients SHOULD implement exponential backoff for issuer requests
- **Status Communication**: Provide clear error messages to clients about service availability

### Network Failure Scenarios

- **Partition Tolerance**: Design systems to handle network partitions between components
- **Offline Operation**: Consider token pre-fetching for offline or low-connectivity scenarios
- **Recovery Procedures**: Implement automatic recovery when network connectivity is restored

### Compromise Response

In case of key compromise or security incidents:

- **Emergency Revocation**: Implement emergency token revocation capabilities
- **Key Rotation**: Rapid key rotation procedures for compromised issuers
- **Incident Response**: Coordinated response procedures for federated deployments
- **Client Notification**: Mechanisms to notify clients of security incidents

# IANA Considerations

## MoQ Authorization Token Types

This document requests IANA to register the following token types in the MoQ Authorization Token Type registry:

| Value  | Token Type                    | Reference |
|--------|-------------------------------|-----------|
| 0x0001 | MoQ-Subscribe Privacy Pass    | This doc  |
| 0x0002 | MoQ-Fetch Privacy Pass        | This doc  |
| 0x0003 | MoQ-Publish Privacy Pass      | This doc  |
| 0x0004 | MoQ-Relay Privacy Pass        | This doc  |

## Privacy Pass Token Type Registry

This document requests IANA to register the following token types in the Privacy Pass Token Type registry:

| Value  | Token Type                    | Reference |
|--------|-------------------------------|-----------|
| 0x0010 | MoQ-Subscribe                 | This doc  |
| 0x0011 | MoQ-Fetch                     | This doc  |
| 0x0012 | MoQ-Publish                   | This doc  |
| 0x0013 | MoQ-Relay                     | This doc  |
| 0x0014 | MoQ-Conference                | This doc  |
| 0x0015 | MoQ-Interactive               | This doc  |

# Deployment Considerations

This section provides guidance for deploying Privacy Pass authentication in MoQ environments.

## Deployment Models

### Single-Provider Model

In a single-provider deployment, one organization operates the issuer, attester, and relay infrastructure:

- **Advantages**: Simplified key management, consistent policies, optimal privacy
- **Use Cases**: Enterprise streaming, internal content distribution
- **Token Type**: Privately verifiable tokens recommended
- **Attestation**: Direct subscriber validation, device certificates

### Multi-Provider Federation

In federated deployments, multiple organizations participate in content delivery:

- **Participants**: Content providers, CDNs, telecommunications operators
- **Advantages**: Broader content reach, resilient infrastructure
- **Use Cases**: Cross-platform content sharing, carrier-grade video services
- **Token Type**: Publicly verifiable tokens enable cross-domain validation
- **Attestation**: Standardized attestation protocols across providers

### Edge Computing Integration

For edge computing scenarios with distributed validation:

- **Architecture**: Edge nodes validate tokens locally without contacting central authority
- **Advantages**: Reduced latency, improved availability
- **Requirements**: Token validation logic must be lightweight and consistent
- **Security**: Edge nodes must be protected against compromise

### Real-time Communication Deployment

For real-time communication applications such as video conferencing and interactive gaming:

- **Ultra-low Latency**: Token validation must complete within strict latency budgets (typically <10ms)
- **High Availability**: Authorization services must maintain 99.9%+ uptime to prevent service disruption
- **Scalability**: Systems must handle thousands of concurrent authorization requests
- **Geographic Distribution**: Validation services should be deployed close to users to minimize network latency
- **Failover Mechanisms**: Redundant authorization paths must be available for mission-critical applications

## Best Practices

### Token Lifecycle Management

1. **Issuance Strategy**:
   - Issue tokens with appropriate validity periods (1-24 hours typical)
   - Implement token prefetching to avoid service interruption
   - Use batch issuance for better performance and privacy

2. **Refresh Mechanisms**:
   - Implement automatic token refresh before expiration
   - Use background refresh to avoid blocking user operations
   - Handle refresh failures gracefully with retry logic

3. **Revocation Handling**:
   - Implement token revocation for policy violations
   - Use revocation lists or short-lived tokens to limit abuse
   - Coordinate revocation across federated deployments

### Security Configuration

1. **Key Management**:
   - Use hardware security modules (HSMs) for issuer private keys
   - Implement regular key rotation (quarterly recommended)
   - Maintain secure key distribution channels

2. **Network Security**:
   - Deploy TLS 1.3 for all communications
   - Use certificate pinning for critical connections
   - Implement proper firewall rules and network segmentation

3. **Monitoring and Alerting**:
   - Monitor token validation rates and error patterns
   - Alert on unusual token usage patterns
   - Implement rate limiting at multiple layers

### Performance Optimization

1. **Caching Strategies**:
   - Cache issuer public keys at relays
   - Implement token validation result caching
   - Use CDN caching for public issuer metadata

2. **Load Distribution**:
   - Distribute token validation across multiple servers
   - Use consistent hashing for token routing
   - Implement circuit breakers for issuer failures

3. **Bandwidth Optimization**:
   - Minimize token metadata size
   - Use token compression where appropriate
   - Batch multiple token presentations

### Privacy Protection

1. **Data Minimization**:
   - Include only necessary metadata in tokens
   - Avoid logging client-identifying information
   - Implement data retention policies

2. **Traffic Analysis Protection**:
   - Use consistent message sizes and timing
   - Implement padding for variable-length metadata
   - Consider using traffic obfuscation techniques

3. **Operational Security**:
   - Separate token issuance from content delivery logging
   - Implement secure audit logging
   - Regular security assessments and penetration testing

## Migration Strategies

### From Traditional Authentication

1. **Gradual Migration**:
   - Run Privacy Pass alongside existing authentication
   - Migrate high-privacy content first
   - Collect performance metrics and user feedback

2. **Compatibility Layer**:
   - Implement adapters for existing authorization systems
   - Maintain backward compatibility during transition
   - Provide fallback mechanisms for legacy clients

### Protocol Upgrades

1. **Version Negotiation**:
   - Implement Privacy Pass version negotiation
   - Support multiple token types during transition
   - Plan for future protocol enhancements

2. **Feature Flags**:
   - Use feature flags to control Privacy Pass deployment
   - Enable gradual rollout to user populations
   - Quick rollback capability for issues

# Implementation Status

This section is to be removed before publishing as an RFC.

This document is currently a proposal and no implementations exist yet.

--- back

# Acknowledgments

The authors would like to thank the Privacy Pass and MoQ working groups for their foundational work that made this specification possible.

# Change Log

This section is to be removed before publishing as an RFC.

## Changes from -00

- Initial version
