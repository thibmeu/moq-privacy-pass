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
  RFC9577:
    title: "The Privacy Pass HTTP Authentication Scheme"
    target: https://www.rfc-editor.org/rfc/rfc9577.txt
  RFC9578:
    title: "Privacy Pass Issuance Protocols"
    target: https://www.rfc-editor.org/rfc/rfc9578.txt
  MoQ-TRANSPORT:
    title: "Media over QUIC Transport"
    target: https://www.ietf.org/archive/id/draft-ietf-moq-transport-12.txt
  RFC2119:
    title: "Key words for use in RFCs to Indicate Requirement Levels"
    target: https://www.rfc-editor.org/rfc/rfc2119.txt

informative:
  RFC9458:
    title: "Oblivious HTTP"
    target: https://www.rfc-editor.org/rfc/rfc9458.txt

--- abstract

This document specifies the use of Privacy Pass architecture and issuance protocols
for authorization in Media over QUIC (MoQ) transport protocol. It defines how 
Privacy Pass tokens can be integrated with MoQ's authorization framework to provide
privacy-preserving authentication for subscriptions, fetches, publications, and relay 
operations while supporting fine-grained access control through prefix-based track 
namespace and track name matching rules.

The integration addresses access control requirements in media streaming scenarios
where traditional authentication methods lack the granular control and privacy 
protection needed for modern media distribution. By leveraging Privacy Pass's 
unlinkable tokens with MoQ-specific metadata, this specification enables scalable
media delivery with precise authorization control and enhanced user privacy.

--- middle

# Introduction

Media over QUIC (MoQ) {{MoQ-TRANSPORT}} provides a transport protocol for live
and on-demand media delivery, real-time communication, and interactive content
distribution over QUIC connections. The protocol supports a wide range of
applications including video streaming, video conferencing, gaming, interactive
broadcasts, and other latency-sensitive use cases. MoQ includes mechanisms for
authorization through tokens that can be used to control access to media
streams, interactive sessions, and relay operations.

Traditional authorization mechanisms often lack the privacy protection needed for
modern media distribution scenarios, where users' viewing patterns and content
preferences should remain private while still enabling fine-grained access control,
namespace restrictions, and operational constraints.

Privacy Pass {{RFC9576}} provides a privacy-preserving authorization architecture
that enables anonymous authentication through unlinkable tokens. The Privacy Pass
architecture consists of four entities: Client, Origin, Issuer, and Attester, which
work together to provide token-based authorization without compromising user privacy.
The issuance protocols {{RFC9578}} define how these tokens are created and verified.

This document defines how Privacy Pass tokens can be integrated with MoQ's 
authorization framework to provide comprehensive access control for media streaming,
real-time communication, and interactive content services while preserving user
privacy through unlinkable authentication tokens.

## Requirements Language

{::boilerplate bcp14-tagged}

# Privacy Pass Architecture for MoQ

The Privacy Pass MoQ integration involves the following entities and their 
interactions:

- **Client**: The MoQ client requesting access to media content. The client is 
responsible for obtaining Privacy Pass tokens through the attestation and 
issuance process, and presenting these tokens when requesting MoQ operations.

- **MoQ Relay/Origin**: The MoQ relay server or origin that forwards media content 
and requires authorization. The relay validates Privacy Pass tokens, enforces access 
policies, and forwards authorized requests to origins or other relays. Relays 
maintain configuration for trusted issuers and validate token signatures and metadata.

- **Privacy Pass Issuer**: The entity that issues Privacy Pass tokens to clients 
after successful attestation. The issuer operates the token issuance protocol, 
manages cryptographic keys, and may implement rate limiting. The issuer creates 
tokens with appropriate MoQ-specific metadata.

- **Privacy Pass Attester**: The entity that attests to properties of clients for 
the purposes of token issuance. The attester verifies client credentials, subscription 
status, or other eligibility criteria. Common attestation methods include 
username/password, OAuth, device certificates, or other authentication mechanisms.

## Integrated Architecture

In integrated deployments, the MoQ relay and Privacy Pass issuer may be operated by 
the same entity to simplify key management and policy coordination:

~~~ascii
         Privacy Pass MoQ Integrated Architecture

┌─────────────┐                               ┌─────────────┐
│   Client    │                               │Privacy Pass │
│             │◄──────────(3)─────────────────│  Attester   │
└─────────────┘                               │             │
       │                                      └─────────────┘
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
┌─────────────┐           (4)             ┌─────────────┐
│   Client    │──────────────────────────►│ MoQ Relay   │
│             │                           │   Origin    │
└─────────────┘                           └─────────────┘

Flow Legend:
(1) Client attestation with Attester
(2) Token issuance from Issuer to Client  
(3) Client requests media access with token
(4) Relay validates token and provides media
~~~

## Separated Architecture

In separated deployments, the MoQ relay and Privacy Pass issuer are operated by 
different entities to enhance privacy through separation of concerns:

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
│             │                               │ (Separate)  │
└─────────────┘                               └─────────────┘
       │                                             │
    (4)│                                          (2)│
       │                                             │
       ▼                                             ▼
┌─────────────┐           (5)             ┌─────────────┐
│ MoQ Relay   │──────────────────────────►│   Origin    │
│             │                           │             │
└─────────────┘                           └─────────────┘

Flow Legend:
(1) Client attestation with separate Attester
(2) Token issuance from separate Issuer to Client
(3) Client requests media access with token from relay
(4) Relay validates token with separate validation service
(5) Relay forwards authorized requests to Origin
~~~

## Trust Model

The architecture assumes the following trust relationships based on the Privacy Pass
architecture {{RFC9576}}:

- **Clients trust issuers** to provide valid tokens and not collude with relays 
to break unlinkability guarantees
- **Relays trust issuers** to properly validate client eligibility before 
issuing tokens
- **Issuers trust attesters** to accurately verify client eligibility
- **Origins trust relays** to enforce access policies correctly
- **No entity trusts any other** to preserve client privacy beyond their 
specific role requirements

# Privacy Pass Token Integration

This section describes how Privacy Pass tokens are integrated into the MoQ 
transport protocol to provide privacy-preserving authorization for various 
media operations.

## Token Types for MoQ Authorization

This specification uses the existing Privacy Pass token types defined in {{RFC9578}}:

- **Token Type 0x0001 (VOPRF(P-384, SHA-384))**: Privately verifiable tokens using 
Verifiable Oblivious Pseudorandom Function for deployments requiring issuer-only 
validation capability.

- **Token Type 0x0002 (Blind RSA (2048-bit))**: Publicly verifiable tokens using 
blind RSA signatures for deployments requiring distributed validation across 
multiple relays.

## Token Structure

Privacy Pass tokens used in MoQ MUST follow the structure defined in {{RFC9577}} 
for the PrivateToken HTTP authentication scheme. The token structure includes:

- **Token Type**: 2-byte identifier specifying the issuance protocol used
- **Nonce**: 32-byte client-generated random value for uniqueness
- **Challenge Digest**: 32-byte SHA-256 hash of the TokenChallenge
- **Token Key ID**: Variable-length identifier for the issuer's public key
- **Authenticator**: Variable-length cryptographic proof bound to the token

### Token Challenge Structure for MoQ

MoQ-specific TokenChallenge structures use the default format defined in {{RFC9577}}
with MoQ-specific parameters in the origin_info field:

```
struct {
    uint16_t token_type;
    opaque issuer_name<1..2^16-1>;
    opaque redemption_context<0..32>;
    opaque origin_info<0..2^16-1>;
} TokenChallenge;
```

For MoQ usage, the origin_info field contains MoQ-specific authorization scope 
information encoded as a UTF-8 string with the following format:

```
moq-scope = operation ":" namespace-pattern [":" track-pattern]
operation = "subscribe" / "fetch" / "publish" / "announce"  
namespace-pattern = exact-match / prefix-match / wildcard-match
track-pattern = exact-match / prefix-match / wildcard-match
exact-match = namespace-string
prefix-match = namespace-string "*"
wildcard-match = "*"
```

Examples:
- `subscribe:sports.example.com/live/*` - Subscribe to any track under live sports
- `fetch:vod.example.com/movies/action*` - Fetch video-on-demand action content
- `publish:user-content.example.com/stream/user123*` - Publish user-generated content
- `announce:*` - Announce any track namespace

## Track Namespace and Track Name Matching Rules

This specification defines prefix-based matching rules for track namespaces and 
track names to enable fine-grained access control while maintaining privacy.

### Namespace Matching

Track namespace matching supports three modes:

**Exact Match**: 
- Pattern: `"example.com/live/sports/soccer"`
- Matches: Only the exact namespace `example.com/live/sports/soccer`
- Use case: Specific content authorization

**Prefix Match**:
- Pattern: `"example.com/live/sports/*"`  
- Matches: Any namespace starting with `example.com/live/sports/`
- Examples: `example.com/live/sports/soccer`, `example.com/live/sports/tennis`
- Use case: Category-based authorization

**Wildcard Match**:
- Pattern: `"*"`
- Matches: Any namespace
- Use case: Unrestricted access within token scope

### Track Name Matching  

Track name matching within authorized namespaces follows the same pattern:

**Exact Match**:
- Pattern: `"video"`
- Matches: Only tracks named exactly `video`

**Prefix Match**:
- Pattern: `"video*"`
- Matches: Any track name starting with `video`
- Examples: `video`, `video-high`, `video-mobile`

**Wildcard Match**:
- Pattern: `"*"`  
- Matches: Any track name within authorized namespace

### Matching Algorithm

Token validation uses the following algorithm:

1. **Extract Authorization Scope**: Parse the MoQ operation and patterns from token metadata
2. **Validate Operation**: Ensure requested operation matches token authorization
3. **Match Namespace**: Apply namespace pattern matching rules
4. **Match Track Name**: If specified, apply track name pattern matching rules
5. **Authorization Decision**: Grant access only if all patterns match

```
function validateMoQToken(token, operation, namespace, trackName) {
    scope = parseTokenScope(token.origin_info)
    
    if (scope.operation != operation) {
        return UNAUTHORIZED
    }
    
    if (!matchPattern(scope.namespace_pattern, namespace)) {
        return UNAUTHORIZED
    }
    
    if (scope.track_pattern && !matchPattern(scope.track_pattern, trackName)) {
        return UNAUTHORIZED
    }
    
    return AUTHORIZED
}

function matchPattern(pattern, value) {
    if (pattern == "*") {
        return true
    } else if (pattern.endsWith("*")) {
        prefix = pattern.substring(0, pattern.length - 1)
        return value.startsWith(prefix)
    } else {
        return pattern == value
    }
}
```

## Token Transfer Methods

Privacy Pass tokens are transferred to MoQ relays using the existing MoQ 
authorization framework with the following adaptations:

### SETUP Message Authorization

For connection-level authorization, Privacy Pass tokens are included in the 
SETUP message's authorization parameter:

```
SETUP {
    Version = 1,
    Parameters = [
        {
            Type = AUTHORIZATION,
            Value = base64url(PrivateTokenAuth)
        }
    ]
}

struct {
    uint8_t auth_scheme = 0x01; // Privacy Pass
    opaque token_data<1..2^16-1>;
} PrivateTokenAuth;
```

### Operation-Level Authorization

For individual operation authorization, tokens are included in operation-specific 
messages:

```
SUBSCRIBE {
    Track_Namespace = "sports.example.com/live/soccer",
    Track_Name = "video", 
    Parameters = [
        {
            Type = AUTHORIZATION,
            Value = base64url(PrivateTokenAuth)
        }
    ]
}
```

# Authorization Flows

This section describes the detailed authorization flows for different MoQ 
operations using Privacy Pass tokens.

## Subscription Authorization

The subscription authorization flow enables privacy-preserving access to media streams:

```ascii
                    Subscription Authorization Flow

   Client      MoQ Relay      Privacy Pass Issuer      Origin
     |            |                    |                |
     |            |                    |                |
     | (1) Request Service Access     |                |
     |----------->|                    |                |
     |            |                    |                |
     |            |  (2) Challenge (TokenChallenge)   |
     |            |<-------------------|                |
     |            |                    |                |
     |  (3) Attestation & Token Request               |
     |--------------------------------->|                |
     |            |                    |                |
     |  (4) Token Response             |                |
     |<---------------------------------|                |
     |            |                    |                |
     |  (5) SUBSCRIBE with Token      |                |
     |----------->|                    |                |
     |            |                    |                |
     |            |  (6) Token Validation              |
     |            |------------------->|                |
     |            |                    |                |
     |            |  (7) Validation Result             |
     |            |<-------------------|                |
     |            |                    |                |
     |            |  (8) Content Request (if authorized)
     |            |------------------------------------>|
     |            |                    |                |
     |            |  (9) Media Stream  |                |
     |            |<------------------------------------|
     |            |                    |                |
     |  (10) SUBSCRIBE_OK + Media     |                |
     |<-----------|                    |                |
     |            |                    |                |
```

### Example: Live Sports Stream

Consider a client subscribing to a live sports stream:

1. **Token Challenge**: Relay issues challenge for `subscribe:sports.example.com/live/*`
2. **Token Issuance**: Client obtains Privacy Pass token through attestation
3. **Subscription Request**: Client sends SUBSCRIBE with token for `sports.example.com/live/soccer`
4. **Authorization**: Relay validates token and namespace match
5. **Media Delivery**: Upon successful authorization, relay delivers media stream

## Fetch Authorization

For object-specific content retrieval:

1. **Token Presentation**: Client includes Privacy Pass token with fetch scope
2. **Object Authorization**: Relay validates token scope covers requested object
3. **Content Delivery**: If authorized, relay retrieves and returns object

## Publication Authorization

For content publication with enhanced policy enforcement:

1. **Announcement**: Client sends ANNOUNCE with Privacy Pass token
2. **Policy Validation**: Relay checks publication authorization and content policies
3. **Publication Setup**: If authorized, relay enables media publishing

# Privacy Considerations

## Unlinkability

To maintain Privacy Pass unlinkability guarantees in MoQ environments:

- Tokens MUST be single-use per MoQ operation to prevent correlation
- Clients SHOULD obtain fresh tokens for different content categories
- Relays MUST NOT log information linking tokens to client identifiers
- Token metadata SHOULD be minimized to prevent fingerprinting

## Metadata Minimization

- Token scopes SHOULD be as broad as practical while meeting security requirements
- Namespace patterns SHOULD use prefix matching rather than exact matching when possible
- Temporal scoping SHOULD be used to limit token lifetime exposure

## Side-Channel Protection

- Token validation MUST use constant-time operations
- Network traffic patterns SHOULD be protected through padding or batching
- Timing correlation between token issuance and usage SHOULD be minimized

# Security Considerations

## Token Validation

Relays MUST properly validate Privacy Pass tokens according to {{RFC9576}}, 
{{RFC9577}}, and {{RFC9578}}:

- **Cryptographic Verification**: Validate token signature using appropriate issuer key
- **Temporal Validation**: Check token expiration and validity period
- **Scope Validation**: Verify token authorizes the requested MoQ operation
- **Replay Protection**: Ensure token hasn't been previously used
- **Namespace Matching**: Validate namespace and track name patterns

## Issuer Trust

Relays MUST maintain a trusted set of Privacy Pass issuers:

- **Key Management**: Implement secure issuer key distribution and rotation
- **Revocation**: Support emergency issuer key revocation
- **Monitoring**: Monitor issuer behavior for policy compliance

## Rate Limiting

- **Issuer-Level**: Issuers SHOULD implement rate limiting on token issuance
- **Relay-Level**: Relays SHOULD implement per-client rate limiting based on token metadata
- **Distributed Coordination**: Multi-relay deployments SHOULD coordinate rate limiting

## Error Handling

- **Token Validation Errors**: Return appropriate error codes without information leakage
- **Issuer Unavailability**: Implement graceful degradation with cached validation
- **Network Failures**: Support offline validation for cached tokens

# IANA Considerations

## Privacy Pass Token Type Registry

This document does not define new Privacy Pass token types. It uses the existing
token types defined in {{RFC9578}}:

- Token Type 0x0001: VOPRF(P-384, SHA-384)
- Token Type 0x0002: Blind RSA (2048-bit)

## MoQ Parameter Registry

This document requests IANA to register the following parameter in the MoQ 
Parameter Registry:

| Parameter Name | Value | Specification |
|===============|=======|===============|
| AUTHORIZATION | TBD   | This document |

# Deployment Considerations

## Token Lifecycle Management

1. **Issuance Strategy**: Issue tokens with appropriate validity periods (1-24 hours typical)
2. **Refresh Mechanisms**: Implement automatic token refresh before expiration  
3. **Revocation Handling**: Support emergency token revocation for policy violations

## Performance Optimization

1. **Caching**: Cache issuer public keys and validation results at relays
2. **Batching**: Use batch token validation for improved performance
3. **Hardware Acceleration**: Leverage hardware cryptography for validation

## Migration from Existing Systems

1. **Gradual Deployment**: Run Privacy Pass alongside existing authentication
2. **Compatibility**: Provide fallback mechanisms for legacy clients
3. **Monitoring**: Collect metrics on adoption and performance impact

# Implementation Status

This section is to be removed before publishing as an RFC.

This document is currently a proposal and no implementations exist yet.

--- back

# Acknowledgments

The authors would like to thank the Privacy Pass and MoQ working groups for 
their foundational work that made this specification possible. Special thanks
to the Privacy Pass architecture authors for their comprehensive framework
and the MoQ transport specification authors for their extensible design.

# Change Log

This section is to be removed before publishing as an RFC.

## Changes from CAT version

- Replaced CAT token format with Privacy Pass tokens per RFC 9576-9578
- Updated architecture section to align with Privacy Pass entities and trust model
- Revised token structure to use Privacy Pass TokenChallenge and Token formats
- Added detailed namespace and track name prefix matching algorithms
- Included comprehensive privacy and security considerations from Privacy Pass
- Aligned IANA considerations with existing Privacy Pass registries